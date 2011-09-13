//
//  SBServer+SickBeardAdditions.m
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBServer+SickBeardAdditions.h"

@implementation SBServer (SickBeardAdditions)

- (BOOL)isValid {
	BOOL isValid = YES;
	
	if (!self.name || self.name.length == 0) {
		isValid = NO;
	}
	
	if (!self.host || self.host.length == 0) {
		isValid = NO;
	}
	
	if ([self.port intValue] <= 0 || [self.port intValue] > 65535) {
		isValid = NO;
	}
	
	if (!self.apiKey || self.apiKey.length == 0) {
		isValid = NO;
	}
	
	return isValid;
}

- (NSString*)serviceEndpointPath {
	return [NSString stringWithFormat:@"http://%@:%@/api/%@/", self.host, self.port, self.apiKey];
}

@end
