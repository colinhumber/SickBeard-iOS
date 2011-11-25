//
//  SickbeardAPIClient.m
//  SickBeard
//
//  Created by Colin Humber on 8/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SickbeardAPIClient.h"
#import "SBCommandBuilder.h"
#import "SBServer.h"
#import "SBServer+SickBeardAdditions.h"
#import "AFJSONRequestOperation.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "NSUserDefaults+SickBeard.h"
#import "SBRootDirectory.h"

NSString *const RESULT_SUCCESS = @"success";
NSString *const RESULT_FAILURE = @"failure";
NSString *const RESULT_TIMEOUT = @"timeout";
NSString *const RESULT_ERROR = @"error";
NSString *const RESULT_FATAL = @"fatal";
NSString *const RESULT_DENIED = @"denied";

static SickbeardAPIClient *sharedClient = nil;

@interface SickbeardAPIClient ()
@property (readwrite, nonatomic, strong) NSOperationQueue *operationQueue;
@end


@implementation SickbeardAPIClient

@synthesize operationQueue;
@synthesize currentServer;

+ (SickbeardAPIClient*)sharedClient {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if (!sharedClient) {
			sharedClient = [[SickbeardAPIClient alloc] init];
		}
	});
	
	return sharedClient;
}

- (NSURL*)posterURL:(NSString*)tvdbID {
	return [self createUrlWithEndpoint:[NSString stringWithFormat:@"showPoster/?show=%@&which=poster", tvdbID]];
}

- (NSURL*)bannerURL:(NSString*)tvdbID {
	return [self createUrlWithEndpoint:[NSString stringWithFormat:@"showPoster/?show=%@&which=banner", tvdbID]];
}

- (id)init {
	self = [super init];
	
	if (self) {
		self.operationQueue = [[NSOperationQueue alloc] init];
		self.operationQueue.maxConcurrentOperationCount = 2;
	}
	
	return self;
}

- (void)loadDefaults:(SBServer*)server {
	NSString *defaultsUrl = [SBCommandBuilder URLForCommand:SickBeardCommandGetDefaults server:server params:nil];
	NSString *dirsUrl = [SBCommandBuilder URLForCommand:SickBeardCommandGetRootDirectories server:server params:nil];
	
	AFJSONRequestOperation *defaultsOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:defaultsUrl]] 
																								success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
																									NSString *result = [JSON objectForKey:@"result"];
																									
																									if ([result isEqualToString:RESULT_SUCCESS]) {
																										NSDictionary *data = [JSON objectForKey:@"data"];
																										
																										NSArray *archives = [SBGlobal qualitiesFromCodes:[data objectForKey:@"archive"]];
																										NSArray *initial = [SBGlobal qualitiesFromCodes:[data objectForKey:@"initial"] ];
																										BOOL useSeasonFolders = [[data objectForKey:@"season_folders"] boolValue];
																										NSString *status = [data objectForKey:@"status"];
																										
																										NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
																										defaults.archiveQualities = [NSMutableArray arrayWithArray:archives];
																										defaults.initialQualities = [NSMutableArray arrayWithArray:initial];
																										defaults.useSeasonFolders = useSeasonFolders;
																										defaults.status = status;
																									
																										[defaults synchronize];
																									}
																								}
																								failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
																									NSLog(@"Error getting defaults: %@", error);
																								}];

	AFJSONRequestOperation *dirsOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:dirsUrl]] 
																							success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
																								NSString *result = [JSON objectForKey:@"result"];
																								
																								if ([result isEqualToString:RESULT_SUCCESS]) {
																									NSArray *data = [JSON objectForKey:@"data"];
																									
																									NSMutableArray *directories = [NSMutableArray arrayWithCapacity:data.count];
																									for (NSDictionary *dir in data) {
																										SBRootDirectory *directory = [SBRootDirectory itemWithDictionary:dir];
																										if (directory.isValid) {
																											[directories addObject:directory];
																										}
																									}
																									NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
																									defaults.defaultDirectories = directories;
																									
																									[defaults synchronize];
																								}
																							}
																							failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
																								NSLog(@"Error getting root dirs: %@", error);
																							}];
	
	[self.operationQueue addOperation:defaultsOperation];
	[self.operationQueue addOperation:dirsOperation];
}


- (void)pingServer:(SBServer*)server success:(APISuccessBlock)success failure:(APIErrorBlock)failure {
	NSAssert(server != nil, @"Server cannot be nil");
	
	NSString *url = [SBCommandBuilder URLForCommand:SickBeardCommandPing server:server params:nil];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
	request.timeoutInterval = 10;

	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
	[self.operationQueue addOperation:operation];
}


- (void)validateServerCredentials:(SBServer*)server success:(void (^)(id object))success failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure {
	NSAssert(server != nil, @"Server cannot be nil");
	
	NSURLCredentialStorage *store = [NSURLCredentialStorage sharedCredentialStorage];
	
	NSURLCredential *credential = [NSURLCredential credentialWithUser:server.username password:server.password persistence:NSURLCredentialPersistenceForSession];
	NSURLProtectionSpace *space = [[NSURLProtectionSpace alloc] initWithHost:server.host port:server.port protocol:NSURLProtectionSpaceHTTP realm:@"SickBeard" authenticationMethod:NSURLAuthenticationMethodDefault];
	[store setDefaultCredential:credential forProtectionSpace:space];

	//	[[NSURLCredentialStorage sharedCredentialStorage] setCredential:credential forProtectionSpace:space];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:server.serviceEndpointPath]];
	request.timeoutInterval = 5;

	// create a plaintext string in the format username:password
	NSString *loginString = [NSString stringWithFormat:@"%@:%@", server.username, server.password];
	
	// create the contents of the header 
	NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@", [loginString base64Encode]];
	
	// add the header to the request.  Here's the $$$!!!
	[request addValue:authHeader forHTTPHeaderField:@"Authorization"];

	AFHTTPRequestOperation *operation = [AFHTTPRequestOperation HTTPRequestOperationWithRequest:request success:success failure:failure];
	[self.operationQueue addOperation:operation];
}


- (void)runCommand:(SickBeardCommand)command parameters:(NSDictionary*)parameters success:(APISuccessBlock)success failure:(APIErrorBlock)failure {
	[self runCommand:command method:HTTPMethodGET parameters:parameters success:success failure:failure];
}


- (void)runCommand:(SickBeardCommand)command method:(SBHTTPMethod)method parameters:(NSDictionary*)parameters success:(APISuccessBlock)success failure:(APIErrorBlock)failure {
	// create custom request for POST. We just work with GET right now
	
	NSString *url = [SBCommandBuilder URLForCommand:command server:self.currentServer params:parameters];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
	
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
	
	// let any hud animations complete before kicking this in
	[self.operationQueue performSelector:@selector(addOperation:) withObject:operation afterDelay:0.2];
}

- (NSURL*)createUrlWithEndpoint:(NSString*)endpoint {
	return [NSURL URLWithString:[self.currentServer.serviceEndpointPath stringByAppendingPathComponent:endpoint]];
}

//- (NSURLRequest*)authenticatedURLRequestForEndpoint:(NSString*)endpoint {
//	NSURL *url = [self createUrlWithEndpoint:endpoint];
//		
//	// create a plaintext string in the format username:password
//	NSString *loginString = [NSString stringWithFormat:@"%@:%@", self.currentServer.username, self.currentServer.password];
//		
//	// create the contents of the header 
//	NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@", [loginString base64Encode]];
//	
//	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];   
//	
//	// add the header to the request.  Here's the $$$!!!
//	[request addValue:authHeader forHTTPHeaderField:@"Authorization"];
//
//	return request;
//}

@end
