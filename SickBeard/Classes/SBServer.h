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
@property (nonatomic) int port;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic) BOOL useSSL;
@property (nonatomic, strong) NSString *proxyUsername;
@property (nonatomic, strong) NSString *proxyPassword;
@property (nonatomic) BOOL isCurrent;

- (BOOL)isValid;
- (NSString*)serviceEndpointPath;

@end
