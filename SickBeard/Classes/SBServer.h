//
//  SBServer.h
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBServer : NSObject <NSCoding>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *host;
@property (nonatomic, assign) int port;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *apiKey;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, assign) BOOL isCurrent;

- (BOOL)isValid;
- (NSString*)serviceEndpointPath;

@end
