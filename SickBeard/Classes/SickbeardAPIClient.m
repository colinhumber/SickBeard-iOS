//
//  SickbeardAPIClient.m
//  SickBeard
//
//  Created by Colin Humber on 8/29/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SickbeardAPIClient.h"
#import "SBCommandBuilder.h"
#import "SBServer.h"
#import "SBServer+SickBeardAdditions.h"
#import "AFJSONRequestOperation.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "NSUserDefaults+SickBeard.h"
#import "SBRootDirectory.h"

#define _AFNETWORKING_ALLOW_INVALID_SSL_CERTIFICATES_

NSString *const RESULT_SUCCESS = @"success";
NSString *const RESULT_FAILURE = @"failure";
NSString *const RESULT_TIMEOUT = @"timeout";
NSString *const RESULT_ERROR = @"error";
NSString *const RESULT_FATAL = @"fatal";
NSString *const RESULT_DENIED = @"denied";

static SickbeardAPIClient *sharedClient = nil;

@interface SickbeardAPIClient ()
@property (nonatomic, strong) NSOperationQueue *operationQueue;
- (void)addAuthenticationToRequest:(NSMutableURLRequest *)request username:(NSString *)username password:(NSString *)password;
@end


@implementation SickbeardAPIClient

+ (SickbeardAPIClient*)sharedClient {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if (!sharedClient) {
			sharedClient = [[SickbeardAPIClient alloc] init];
		}
	});
	
	return sharedClient;
}

- (NSURL*)posterURLForTVDBID:(NSString*)tvdbID {
	NSDictionary *parameters = [NSDictionary dictionaryWithObject:tvdbID forKey:@"tvdbid"];
	NSString *url = [SBCommandBuilder URLForCommand:SickBeardCommandShowGetPoster server:self.currentServer params:parameters];
	return [NSURL URLWithString:url];
}

- (NSURL*)bannerURLForTVDBID:(NSString*)tvdbID {
	NSDictionary *parameters = [NSDictionary dictionaryWithObject:tvdbID forKey:@"tvdbid"];
	NSString *url = [SBCommandBuilder URLForCommand:SickBeardCommandShowGetBanner server:self.currentServer params:parameters];
	return [NSURL URLWithString:url];
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
	NSArray *commands = [NSArray arrayWithObjects:
						 [NSNumber numberWithInteger:SickBeardCommandGetDefaults],
						 [NSNumber numberWithInteger:SickBeardCommandGetRootDirectories], 
						 nil];
	NSString *defaultsUrl = [SBCommandBuilder URLForCommands:commands server:server params:nil];
	NSMutableURLRequest *defaultsRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:defaultsUrl]];

	if (server.proxyUsername && server.proxyPassword) {
		[self addAuthenticationToRequest:defaultsRequest username:server.proxyUsername password:server.proxyPassword];
	}
	
	AFJSONRequestOperation *defaultsOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:defaultsRequest
																								success:^(NSURLRequest *request, NSURLResponse *response, id JSON) {
																									NSString *result = [JSON objectForKey:@"result"];
																									
																									if ([result isEqualToString:RESULT_SUCCESS]) {
																										NSDictionary *data = [JSON objectForKey:@"data"];
																										NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
																										
																										// DEFAULTS
																										NSDictionary *defaultsDict = [data objectForKey:@"sb.getdefaults"];
																										NSDictionary *defaultsData = [defaultsDict objectForKey:@"data"];
																										NSArray *archives = [SBGlobal qualitiesFromCodes:[defaultsData objectForKey:@"archive"]];
																										NSArray *initial = [SBGlobal qualitiesFromCodes:[defaultsData objectForKey:@"initial"] ];
																										BOOL useSeasonFolders = [[defaultsData objectForKey:@"season_folders"] boolValue];
																										NSString *status = [defaultsData objectForKey:@"status"];
																										
																										defaults.archiveQualities = [NSMutableArray arrayWithArray:archives];
																										defaults.initialQualities = [NSMutableArray arrayWithArray:initial];
																										defaults.useSeasonFolders = useSeasonFolders;
																										defaults.status = status;
																									
																										// ROOT DIRECTORIES
																										NSDictionary *dirsDict = [data objectForKey:@"sb.getrootdirs"];
																										NSArray *dirsData = [dirsDict objectForKey:@"data"];

																										NSMutableArray *directories = [NSMutableArray arrayWithCapacity:dirsData.count];
																										for (NSDictionary *dir in dirsData) {
																											SBRootDirectory *directory = [SBRootDirectory itemWithDictionary:dir];
																											if (directory.isValid) {
																												[directories addObject:directory];
																											}
																										}
																										
																										defaults.defaultDirectories = directories;
																										
																										[defaults synchronize];
																									}
																								}
																								failure:^(NSURLRequest *request, NSURLResponse *response, NSError *error, id JSON) {
																									NSLog(@"Error getting defaults: %@", error);
																								}];
	
	[self.operationQueue addOperation:defaultsOperation];
}


- (void)pingServer:(SBServer*)server success:(APISuccessBlock)success failure:(APIErrorBlock)failure {
	NSAssert(server != nil, @"Server cannot be nil");
	
	NSString *url = [SBCommandBuilder URLForCommand:SickBeardCommandPing server:server params:nil];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
	request.timeoutInterval = 10;
	
	if (server.proxyUsername && server.proxyPassword) {
		[self addAuthenticationToRequest:request username:server.proxyUsername password:server.proxyPassword];
	}

	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
	[self.operationQueue addOperation:operation];
}


- (void)runCommand:(SickBeardCommand)command parameters:(NSDictionary*)parameters success:(APISuccessBlock)success failure:(APIErrorBlock)failure {
	[self runCommand:command method:HTTPMethodGET parameters:parameters success:success failure:failure];
}

- (void)runCommand:(SickBeardCommand)command method:(SBHTTPMethod)method parameters:(NSDictionary*)parameters success:(APISuccessBlock)success failure:(APIErrorBlock)failure {
	// create custom request for POST. We just work with GET right now
	
	NSString *url = [SBCommandBuilder URLForCommand:command server:self.currentServer params:parameters];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];

	if (self.currentServer.proxyUsername && self.currentServer.proxyPassword) {
		[self addAuthenticationToRequest:request username:self.currentServer.proxyUsername password:self.currentServer.proxyPassword];
	}
	
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
	
	// let any hud animations complete before kicking this in
	[self.operationQueue performSelector:@selector(addOperation:) withObject:operation afterDelay:0.2];
}

- (NSURL*)createUrlWithEndpoint:(NSString*)endpoint {
	return [NSURL URLWithString:[self.currentServer.serviceEndpointPath stringByAppendingPathComponent:endpoint]];
}

- (void)addAuthenticationToRequest:(NSMutableURLRequest *)request username:(NSString *)username password:(NSString *)password {
	// create a plaintext string in the format username:password
	NSString *loginString = [NSString stringWithFormat:@"%@:%@", username, password];
		
	// create the contents of the header 
	NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@", [loginString base64Encode]];
		
	// add the header to the request.  Here's the $$$!!!
	[request addValue:authHeader forHTTPHeaderField:@"Authorization"];
}

@end
