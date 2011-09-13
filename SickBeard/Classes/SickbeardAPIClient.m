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

static SickbeardAPIClient *sharedClient = nil;

@interface SickbeardAPIClient ()
@property (readwrite, nonatomic, retain) NSOperationQueue *operationQueue;
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

- (id)init {
	self = [super init];
	
	if (self) {
		self.operationQueue = [[[NSOperationQueue alloc] init] autorelease];
		self.operationQueue.maxConcurrentOperationCount = 2;
	}
	
	return self;
}

- (void)dealloc {
	self.operationQueue = nil;
	self.currentServer = nil;
	[super dealloc];
}

- (void)pingServer:(SBServer*)server success:(APISuccessBlock)success failure:(APIErrorBlock)failure {
	NSAssert(server != nil, @"Server cannot be nil");
	
	NSString *serverUrl = [NSString stringWithFormat:@"%@/api/%@/?cmd=sb.ping", server.serviceEndpointPath, server.apiKey];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:serverUrl]];

	AFJSONRequestOperation *operation = [AFJSONRequestOperation operationWithRequest:request success:success failure:failure];
	[self.operationQueue addOperation:operation];
}

- (void)runCommand:(SickBeardCommand)command parameters:(NSDictionary*)parameters success:(APISuccessBlock)success failure:(APIErrorBlock)failure {
	[self runCommand:command method:HTTPMethodGET parameters:parameters success:success failure:failure];
}

- (void)runCommand:(SickBeardCommand)command method:(SBHTTPMethod)method parameters:(NSDictionary*)parameters success:(APISuccessBlock)success failure:(APIErrorBlock)failure {
	// create custom request for POST. We just work with GET right now
	
	NSString *url = [SBCommandBuilder URLForCommand:command server:self.currentServer params:parameters];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
	
	NSLog(@"Request created: %@", url);
	
	AFJSONRequestOperation *operation = [AFJSONRequestOperation operationWithRequest:request success:success failure:failure];
	[self.operationQueue addOperation:operation];
}

- (NSURL*)createUrlWithEndpoint:(NSString*)endpoint {
	return [NSURL URLWithString:[self.currentServer.serviceEndpointPath stringByAppendingPathComponent:endpoint]];
}

@end
