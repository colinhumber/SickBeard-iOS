//
//  SBEpisode.m
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBEpisode.h"
#import "SBShow.h"
#import "NSDate+Utilities.h"

@implementation SBEpisode

- (id)initWithDictionary:(NSDictionary*)dict {
	self = [super init];
	
	if (self) {
		self.airDate = [NSDate dateWithString:dict[@"airdate"]];
		self.episodeDescription = dict[@"description"];
		self.location = dict[@"location"];
		self.name = dict[@"name"];
		
		NSString *statusString = [dict[@"status"] lowercaseString];
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
		else if ([statusString isEqualToString:@"snatched"]) {
			self.status = EpisodeStatusSnatched;
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
	return [[self alloc] initWithDictionary:dict];
}

- (NSString*)description {
	return [NSString stringWithFormat:@"<%@ = %8@ | name = %@ | episode = S%luE%lu>", [self class], self, self.name, self.season, self.number];
}



@end
