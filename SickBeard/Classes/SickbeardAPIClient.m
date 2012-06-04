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

- (NSURL*)posterURLForTVDBID:(NSString*)tvdbID {
	NSDictionary *parameters = [NSDictionary dictionaryWithObject:tvdbID forKey:@"tvdbid"];
	NSString *url = [SBCommandBuilder URLForCommand:SickBeardCommandShowGetPoster server:self.currentServer params:parameters];
	return [NSURL URLWithString:url];
	//return [self createUrlWithEndpoint:[NSString stringWithFormat:@"showPoster/?show=%@&which=poster", tvdbID]];
}

- (NSURL*)bannerURLForTVDBID:(NSString*)tvdbID {
	NSDictionary *parameters = [NSDictionary dictionaryWithObject:tvdbID forKey:@"tvdbid"];
	NSString *url = [SBCommandBuilder URLForCommand:SickBeardCommandShowGetBanner server:self.currentServer params:parameters];
	return [NSURL URLWithString:url];

	//	return [self createUrlWithEndpoint:[NSString stringWithFormat:@"showPoster/?show=%@&which=banner", tvdbID]];
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
																								success:^(NSURLRequest *request, NSURLResponse *response, id JSON) {
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
																								failure:^(NSURLRequest *request, NSURLResponse *response, NSError *error, id JSON) {
																									NSLog(@"Error getting defaults: %@", error);
																								}];

	AFJSONRequestOperation *dirsOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:dirsUrl]] 
																							success:^(NSURLRequest *request, NSURLResponse *response, id JSON) {
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
																							failure:^(NSURLRequest *request, NSURLResponse *response, NSError *error, id JSON) {
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

@end
