//
//  SBBaseEpisode.h
//  SickBeard
//
//  Created by Colin Humber on 4/24/12.
//  Copyright (c) 2012 Colin Humber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBShow.h"

typedef NS_ENUM(NSInteger, EpisodeStatus) {
	EpisodeStatusUnknown = -1,
	EpisodeStatusWanted = 0,
	EpisodeStatusSkipped = 1,
	EpisodeStatusArchived = 2,
	EpisodeStatusIgnored = 3,
	EpisodeStatusUnaired = 4,
	EpisodeStatusDownloaded = 5,
	EpisodeStatusSnatched = 6
};


@interface SBBaseEpisode : NSObject

@property (nonatomic, strong) NSDate *airDate;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSUInteger season;
@property (nonatomic, assign) NSUInteger number;
@property (nonatomic, strong) NSString *episodeDescription;
@property (nonatomic, strong) SBShow *show;

+ (NSString*)episodeStatusAsString:(EpisodeStatus)status;

@end
