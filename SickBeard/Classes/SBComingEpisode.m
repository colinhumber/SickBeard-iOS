//
//  SBComingEpisode.m
//  SickBeard
//
//  Created by Colin Humber on 9/2/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBComingEpisode.h"
#import "SBShow.h"
#import "NSDate+Utilities.h"

@implementation SBComingEpisode

//@synthesize airDate;
@synthesize airs;
@synthesize name;
//@synthesize plot;
//@synthesize network;
//@synthesize quality;
//@synthesize season;
//@synthesize number;
//@synthesize showName;
//@synthesize showStatus;
//@synthesize tvdbID;
@synthesize weekday;

- (id)initWithDictionary:(NSDictionary*)dict {
	self = [super init];
	
	if (self) {		
		self.airDate = [NSDate dateWithString:[dict objectForKey:@"airdate"]];		
		self.airs = [dict objectForKey:@"airs"];
		self.name = [dict objectForKey:@"ep_name"];
		self.episodeDescription = [[dict objectForKey:@"ep_plot"] length] > 0 ? [dict objectForKey:@"ep_plot"] : @"No plot summary available"; 
		self.season = [[dict objectForKey:@"season"] intValue];
		self.number = [[dict objectForKey:@"episode"] intValue];
		self.weekday = [dict objectForKey:@"weekday"];
		
		SBShow *show = [[SBShow alloc] init];

		NSString *qualityString = [dict objectForKey:@"quality"];
		if ([qualityString rangeOfString:@"HD"].location != NSNotFound) {
			show.quality = ShowQualityHD;
		}
		else if ([qualityString rangeOfString:@"SD"].location != NSNotFound) {
			show.quality = ShowQualitySD;
		}
		else if ([qualityString rangeOfString:@"Custom"].location != NSNotFound) {
			show.quality = ShowQualityCustom;
		}
		else {
			show.quality = ShowQualityUnknown;
		}
		
		NSString *stat = [[dict objectForKey:@"show_status"] lowercaseString];
		
		if ([stat isEqualToString:@"continuing"]) {
			show.status = ShowStatusContinuing;
		}
		else if ([stat isEqualToString:@"ended"]) {
			show.status = ShowStatusEnded;
		}
		else {
			show.status = ShowStatusUnknown;
		}
		
		show.network = [dict objectForKey:@"network"];
		show.showName = [dict objectForKey:@"show_name"];
		show.tvdbID = [dict objectForKey:@"tvdbid"];
		
		self.show = show;
	}
	
	return self;
}

+ (id)itemWithDictionary:(NSDictionary*)dict {
	return [[self alloc] initWithDictionary:dict];
}

- (NSString*)description {
	return [NSString stringWithFormat:@"<%@ = %8@ | name = %@ | show = %@>", [self class], self, name, self.show];
}


@end
