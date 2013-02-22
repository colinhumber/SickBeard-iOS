//
//  SBRootDirectory.m
//  SickBeard
//
//  Created by Colin Humber on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBRootDirectory.h"

@implementation SBRootDirectory

@synthesize isDefault;
@synthesize path;
@synthesize isValid;

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeBool:isDefault forKey:@"isDefault"];
	[encoder encodeObject:path forKey:@"path"];
	[encoder encodeBool:isValid forKey:@"isValid"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	
	if (self) {
		self.isDefault = [decoder decodeBoolForKey:@"isDefault"];
		self.path = [decoder decodeObjectForKey:@"path"];
		self.isValid = [decoder decodeBoolForKey:@"isValid"];
	}
	
	return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
	self = [super init];
	
	if (self) {
		self.isDefault = [[dict objectForKey:@"default"] boolValue];
		self.path = [dict objectForKey:@"location"];
		self.isValid = [[dict objectForKey:@"valid"] boolValue];
	}
	
	return self;
}

+ (id)itemWithDictionary:(NSDictionary*)dict {
	return [[self alloc] initWithDictionary:dict];
}

- (NSString*)description {
	return [NSString stringWithFormat:@"<%@ = %8@ | isDefault = %d | path = %@ | isValid = %d>", [self class], self, isDefault, path, isValid];
}

@end
