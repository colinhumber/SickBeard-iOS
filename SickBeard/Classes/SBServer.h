//
//  SBServer.h
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBServer : NSObject <NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, assign) int port;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) BOOL isCurrent;

- (BOOL)isValid;
- (NSString*)serviceEndpointPath;

@end
