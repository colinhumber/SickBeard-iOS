//
//  SickbeardAPIClient.h
//  SickBeard
//
//  Created by Colin Humber on 8/29/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@class SBServer;

extern NSString *const RESULT_SUCCESS;
extern NSString *const RESULT_FAILURE;
extern NSString *const RESULT_TIMEOUT;
extern NSString *const RESULT_ERROR;
extern NSString *const RESULT_FATAL;
extern NSString *const RESULT_DENIED;

typedef NS_ENUM(NSInteger, SBHTTPMethod) {
	HTTPMethodGET,
	HTTPMethodPOST
};

typedef void (^APISuccessBlock)(NSURLSessionDataTask *task, id JSON);
typedef void (^APIErrorBlock)(NSURLSessionDataTask *task, NSError *error);

@interface SickbeardAPIClient : AFHTTPSessionManager

- (NSURL*)posterURLForTVDBID:(NSString*)tvdbID;
- (NSURL*)bannerURLForTVDBID:(NSString*)tvdbID;

// loads defaults and root directories for the specified server
- (void)loadDefaults;

// runs API commands against a pre-defined server
- (void)runCommand:(SickBeardCommand)command parameters:(NSDictionary *)params success:(APISuccessBlock)success failure:(APIErrorBlock)failure;

@end
