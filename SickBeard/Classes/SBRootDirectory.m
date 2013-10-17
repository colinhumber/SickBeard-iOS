//
//  SBRootDirectory.m
//  SickBeard
//
//  Created by Colin Humber on 11/8/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
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
		self.isDefault = [dict[@"default"] boolValue];
		self.path = dict[@"location"];
		self.isValid = [dict[@"valid"] boolValue];
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
