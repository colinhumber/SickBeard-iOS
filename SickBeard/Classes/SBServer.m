//
//  SBServer.m
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBServer.h"


@implementation SBServer

@synthesize name;
@synthesize host;
@synthesize port;
@synthesize path;
@synthesize username;
@synthesize apiKey;
@synthesize password;
@synthesize isCurrent;

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:name forKey:@"name"];
	[encoder encodeObject:host forKey:@"host"];
	[encoder encodeInt:port forKey:@"port"];
	[encoder encodeObject:path forKey:@"path"];
	[encoder encodeObject:username forKey:@"username"];
	[encoder encodeObject:password forKey:@"password"];
	[encoder encodeObject:apiKey forKey:@"apiKey"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	
	if (self) {
		self.name = [decoder decodeObjectForKey:@"name"];
		self.host = [decoder decodeObjectForKey:@"host"];
		self.port = [decoder decodeIntForKey:@"port"];
		self.path = [decoder decodeObjectForKey:@"path"];
		self.username = [decoder decodeObjectForKey:@"username"];
		self.password = [decoder decodeObjectForKey:@"password"];
		self.apiKey = [decoder decodeObjectForKey:@"apiKey"];
	}
	
	return self;
}

- (BOOL)isValid {
	BOOL isValid = YES;
	
	if (!self.name || self.name.length == 0) {
		isValid = NO;
	}
	
	if (!self.host || self.host.length == 0) {
		isValid = NO;
	}
	
	if (self.port <= 0 || self.port > 65535) {
		isValid = NO;
	}
	
	if (!self.apiKey || self.apiKey.length == 0) {
		isValid = NO;
	}
	
	return isValid;
}

- (NSString*)serviceEndpointPath {
	NSString *endpoint = [NSString stringWithFormat:@"http://%@:%d/", self.host, self.port];
	
	if (self.path) {
		endpoint = [endpoint stringByAppendingFormat:@"%@/", self.path];
	}
	
	return endpoint;
}

@end
