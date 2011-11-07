//
//  SBEpisode.h
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DictionaryCreation.h"

@class SBShow;

typedef enum {
	EpisodeStatusUnknown = -1,
	EpisodeStatusWanted = 0,
	EpisodeStatusSkipped = 1,
	EpisodeStatusArchived = 2,
	EpisodeStatusIgnored = 3,
	EpisodeStatusUnaired = 4,
	EpisodeStatusDownloaded = 5
} EpisodeStatus;

@interface SBEpisode : NSObject <DictionaryCreation>

@property (nonatomic, strong) NSDate *airDate;
@property (nonatomic, strong) NSString *episodeDescription;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) EpisodeStatus status;
@property (nonatomic) int season;
@property (nonatomic) int number;
@property (nonatomic, strong) SBShow *show;

+ (NSString*)episodeStatusAsString:(EpisodeStatus)status;

@end
