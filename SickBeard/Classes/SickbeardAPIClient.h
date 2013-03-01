//
//  SickbeardAPIClient.h
//  SickBeard
//
//  Created by Colin Humber on 8/29/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

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

typedef void (^APISuccessBlock)(AFHTTPRequestOperation *operation, id JSON);
typedef void (^APIErrorBlock)(AFHTTPRequestOperation *operation, NSError *error);

@interface SickbeardAPIClient : AFHTTPClient

- (NSURL*)posterURLForTVDBID:(NSString*)tvdbID;
- (NSURL*)bannerURLForTVDBID:(NSString*)tvdbID;

// loads defaults and root directories for the specified server
- (void)loadDefaults;

// runs API commands against a pre-defined server
- (void)runCommand:(SickBeardCommand)command parameters:(NSDictionary *)params success:(APISuccessBlock)success failure:(APIErrorBlock)failure;


@end
