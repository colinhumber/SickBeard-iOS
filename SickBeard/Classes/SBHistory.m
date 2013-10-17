//
//  SBHistory.m
//  SickBeard
//
//  Created by Colin Humber on 11/8/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBHistory.h"
#import "NSDate+Utilities.h"

@implementation SBHistory

@synthesize createdDate;
@synthesize quality;
@synthesize showName;
@synthesize season;
@synthesize episode;
@synthesize tvdbID;

- (id)initWithDictionary:(NSDictionary *)dict {
	self = [super init];
	
	if (self) {
		self.createdDate = [NSDate dateTimeWithString:dict[@"date"]];
		self.quality = dict[@"quality"];
		self.showName = dict[@"show_name"];
		self.season = [dict[@"season"] intValue];
		self.episode = [dict[@"episode"] intValue];
		self.tvdbID = dict[@"tvdbid"];
	}
	
	return self;
}

+ (id)itemWithDictionary:(NSDictionary *)dict {
	return [[self alloc] initWithDictionary:dict];
}

- (NSString*)description {
	return [NSString stringWithFormat:@"<%@ = %8@ | show = %@ | tvdbID = %@ | created date = %@>", [self class], self, showName, tvdbID, createdDate];
}

@end
