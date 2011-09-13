//
//  SBEpisode.m
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBEpisode.h"
#import "SBShow.h"

@implementation SBEpisode

@synthesize airDate;
@synthesize episodeDescription;
@synthesize location;
@synthesize name;
@synthesize status;
@synthesize season;
@synthesize number;
@synthesize show;

- (id)initWithDictionary:(NSDictionary*)dict {
	self = [super init];
	
	if (self) {
		self.airDate = [dict objectForKey:@"airdate"];
		self.episodeDescription = [dict objectForKey:@"description"];
		self.location = [dict objectForKey:@"location"];
		self.name = [dict objectForKey:@"name"];
		
		NSString *statusString = [[dict objectForKey:@"status"] lowercaseString];
		if ([statusString isEqualToString:@"ignored"]) {
			self.status = EpisodeStatusIgnored;
		}
		else if ([statusString isEqualToString:@"skipped"]) {
			self.status = EpisodeStatusSkipped;
		}
		else if ([statusString isEqualToString:@"wanted"]) {
			self.status = EpisodeStatusWanted;
		}
		else if ([statusString isEqualToString:@"unaired"]) {
			self.status = EpisodeStatusUnaired;
		}
		else if ([statusString isEqualToString:@"archived"]) {
			self.status = EpisodeStatusArchived;
		}
		else if ([statusString rangeOfString:@"downloaded"].location != NSNotFound) {
			self.status = EpisodeStatusDownloaded;
		}
		else {
			self.status = EpisodeStatusUnknown;
		}		
	}
	
	return self;
}

+ (id)itemWithDictionary:(NSDictionary*)dict {
	return [[[self alloc] initWithDictionary:dict] autorelease];
}

- (NSString*)description {
	return [NSString stringWithFormat:@"<%@ = %08X | name = %@ | number = %d>", [self class], self, name, number];
}

+ (NSString*)episodeStatusAsString:(EpisodeStatus)status {
	switch (status) {
		case EpisodeStatusArchived:
			return @"archived";
			
		case EpisodeStatusDownloaded:
			return @"downloaded";
			
		case EpisodeStatusIgnored:
			return @"ignored";
			
		case EpisodeStatusSkipped:
			return @"skipped";
			
		case EpisodeStatusUnaired:
			return @"unaired";
			
		case EpisodeStatusWanted:
			return @"wanted";
			
		default:
			return @"unknown";
	}
}

- (void)dealloc {
	[airDate release];
	[episodeDescription release];
	[location release];
	[name release];
	[show release];
	[super dealloc];
}

@end
