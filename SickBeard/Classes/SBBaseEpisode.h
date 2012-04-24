//
//  SBBaseEpisode.h
//  SickBeard
//
//  Created by Colin Humber on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBShow.h"

typedef enum {
	EpisodeStatusUnknown = -1,
	EpisodeStatusWanted = 0,
	EpisodeStatusSkipped = 1,
	EpisodeStatusArchived = 2,
	EpisodeStatusIgnored = 3,
	EpisodeStatusUnaired = 4,
	EpisodeStatusDownloaded = 5,
	EpisodeStatusSnatched = 6
} EpisodeStatus;


@interface SBBaseEpisode : NSObject

@property (nonatomic, strong) NSDate *airDate;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int season;
@property (nonatomic, assign) int number;
@property (nonatomic, strong) NSString *episodeDescription;

@property (nonatomic, strong) SBShow *show;
//@property (nonatomic, strong) NSString *showName;
//@property (nonatomic, strong) NSString *showStatus;
//@property (nonatomic, strong) NSString *tvdbID;
//@property (nonatomic, strong) NSString *network;
//@property (nonatomic, strong) NSString *quality;

+ (NSString*)episodeStatusAsString:(EpisodeStatus)status;

@end
