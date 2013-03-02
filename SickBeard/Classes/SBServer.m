//
//  SBServer.m
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBServer.h"


@implementation SBServer

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.name forKey:@"name"];
	[encoder encodeObject:self.host forKey:@"host"];
	[encoder encodeInt:self.port forKey:@"port"];
	[encoder encodeObject:self.path forKey:@"path"];
	[encoder encodeBool:self.useSSL forKey:@"useSSL"];
	[encoder encodeObject:self.apiKey forKey:@"apiKey"];
	[encoder encodeObject:self.proxyUsername forKey:@"proxyUsername"];
	[encoder encodeObject:self.proxyPassword forKey:@"proxyPassword"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	
	if (self) {
		self.name = [decoder decodeObjectForKey:@"name"];
		self.host = [decoder decodeObjectForKey:@"host"];
		self.port = [decoder decodeIntForKey:@"port"];
		self.path = [decoder decodeObjectForKey:@"path"];
		self.useSSL = [decoder decodeBoolForKey:@"useSSL"];
		self.apiKey = [decoder decodeObjectForKey:@"apiKey"];
		self.proxyUsername = [decoder decodeObjectForKey:@"proxyUsername"];
		self.proxyPassword = [decoder decodeObjectForKey:@"proxyPassword"];
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
	NSString *protocol = self.useSSL ? @"https" : @"http";
	NSString *endpoint = [NSString stringWithFormat:@"%@://%@:%d/", protocol, self.host, self.port];
	
	if (self.path.length > 0) {
		endpoint = [endpoint stringByAppendingFormat:@"%@/", self.path];
	}
	
	endpoint = [endpoint stringByAppendingFormat:@"api/%@/", self.apiKey];
	
	return endpoint;
}

@end
