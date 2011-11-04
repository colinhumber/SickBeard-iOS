//
//  SickbeardAPIClient.h
//  SickBeard
//
//  Created by Colin Humber on 8/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class SBServer;

extern NSString *const RESULT_SUCCESS;
extern NSString *const RESULT_FAILURE;
extern NSString *const RESULT_TIMEOUT;
extern NSString *const RESULT_ERROR;
extern NSString *const RESULT_FATAL;
extern NSString *const RESULT_DENIED;

typedef enum {
	HTTPMethodGET,
	HTTPMethodPOST
} SBHTTPMethod;

typedef void (^APISuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON);
typedef void (^APIErrorBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error);

@interface SickbeardAPIClient : NSObject

+ (SickbeardAPIClient*)sharedClient;

// tests an undefined server to see if it is valid or not
- (void)pingServer:(SBServer*)server success:(APISuccessBlock)success failure:(APIErrorBlock)failure;

// runs API commands against a pre-defined server
- (void)runCommand:(SickBeardCommand)command parameters:(NSDictionary*)params success:(APISuccessBlock)success failure:(APIErrorBlock)failure;
- (void)runCommand:(SickBeardCommand)command method:(SBHTTPMethod)method parameters:(NSDictionary*)params success:(APISuccessBlock)success failure:(APIErrorBlock)failure;

// create URL endpoint directly against the server
- (NSURL*)createUrlWithEndpoint:(NSString*)endpoint;

@property (nonatomic, strong) SBServer *currentServer;

@end
