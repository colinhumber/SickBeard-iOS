//
//  SBComingEpisode.m
//  SickBeard
//
//  Created by Colin Humber on 9/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBComingEpisode.h"
#import "NSDate+Utilities.h"

@implementation SBComingEpisode

@synthesize airDate;
@synthesize airs;
@synthesize name;
@synthesize plot;
@synthesize network;
@synthesize quality;
@synthesize season;
@synthesize number;
@synthesize showName;
@synthesize showStatus;
@synthesize tvdbID;
@synthesize weekday;

- (id)initWithDictionary:(NSDictionary*)dict {
	self = [super init];
	
	if (self) {		
		self.airDate = [NSDate dateWithString:[dict objectForKey:@"airdate"]];		
		self.airs = [dict objectForKey:@"airs"];
		self.name = [dict objectForKey:@"ep_name"];
		self.plot = [[dict objectForKey:@"ep_plot"] length] > 0 ? [dict objectForKey:@"ep_plot"] : @"No plot summary available"; 
		self.network = [dict objectForKey:@"network"];
		self.quality = [dict objectForKey:@"quality"];
		self.season = [[dict objectForKey:@"season"] intValue];
		self.number = [[dict objectForKey:@"episode"] intValue];
		self.showName = [dict objectForKey:@"show_name"];
		self.showStatus = [dict objectForKey:@"show_status"];
		self.tvdbID = [dict objectForKey:@"tvdbid"];
		self.weekday = [dict objectForKey:@"weekday"];
	}
	
	return self;
}

+ (id)itemWithDictionary:(NSDictionary*)dict {
	return [[self alloc] initWithDictionary:dict];
}

- (NSString*)description {
	return [NSString stringWithFormat:@"<%@ = %08X | name = %@ | show_name = %@>", [self class], self, name, showName];
}


@end
