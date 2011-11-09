//
//  SBHistory.m
//  SickBeard
//
//  Created by Colin Humber on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
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
		self.createdDate = [NSDate dateTimeWithString:[dict objectForKey:@"date"]];
		self.quality = [dict objectForKey:@"quality"];
		self.showName = [dict objectForKey:@"show_name"];
		self.season = [[dict objectForKey:@"season"] intValue];
		self.episode = [[dict objectForKey:@"episode"] intValue];
		self.tvdbID = [dict objectForKey:@"tvdbid"];
	}
	
	return self;
}

+ (id)itemWithDictionary:(NSDictionary *)dict {
	return [[self alloc] initWithDictionary:dict];
}

- (NSString*)description {
	return [NSString stringWithFormat:@"<%@ = %08X | show = %d | tvdbID = %@ | created date = %@>", [self class], self, showName, tvdbID, createdDate];
}

@end
