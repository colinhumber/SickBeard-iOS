//
//  SBBaseEpisode.m
//  SickBeard
//
//  Created by Colin Humber on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SBBaseEpisode.h"

@implementation SBBaseEpisode

@synthesize airDate = _airDate;
@synthesize name = _name;
@synthesize season = _season;
@synthesize number = _number;
@synthesize episodeDescription = _episodeDescription;
@synthesize show = _show;

- (void)setEpisodeDescription:(NSString *)ed {
	if (ed == nil || ed.length == 0) {
		_episodeDescription = NSLocalizedString(@"No episode description", @"No episode description");
	}
	else {
		_episodeDescription = ed;
	}
}

+ (NSString*)episodeStatusAsString:(EpisodeStatus)status {
	switch (status) {
		case EpisodeStatusArchived:
			return NSLocalizedString(@"Archived", @"Archived");
			
		case EpisodeStatusDownloaded:
			return NSLocalizedString(@"Downloaded", @"Downloaded");
			
		case EpisodeStatusIgnored:
			return NSLocalizedString(@"Ignored", @"Ignored");
			
		case EpisodeStatusSkipped:
			return NSLocalizedString(@"Skipped", @"Skipped");
			
		case EpisodeStatusSnatched:
			return NSLocalizedString(@"Snatched", @"Snatched");
			
		case EpisodeStatusUnaired:
			return NSLocalizedString(@"Unaired", @"Unaired");
			
		case EpisodeStatusWanted:
			return NSLocalizedString(@"Wanted", @"Wanted");
			
		default:
			return NSLocalizedString(@"Unknown", @"Unknown");
	}
}

@end
