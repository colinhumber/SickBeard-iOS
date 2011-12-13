//
//  SBGlobal.h
//  SickBeard
//
//  Created by Colin Humber on 8/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderedDictionary.h"

#define RGBCOLOR(r, g, b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1]
#define RGBACOLOR(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

#define kTVDBLinkFormat @"http://thetvdb.com/?tab=series&id=%@&lid=7"
#define kTVRageLinkFormat @"http://www.tvrage.com/shows/id-%@"

typedef enum {
	// system commands
	SickBeardCommandCheckScheduler,
	SickBeardCommandGetDefaults,
	SickBeardCommandForceSearch,
	SickBeardCommandPauseBacklog,
	SickBeardCommandPing,
	SickBeardCommandRestart,
	SickBeardCommandSetDefaults,
	SickBeardCommandShutdown,
	SickBeardCommandGetRootDirectories,
	SickBeardCommandAddRootDirectory,
	SickBeardCommandDeleteRootDirectory,
	SickBeardCommandSearchTVDB,
	
	// episode commands
	SickBeardCommandComingEpisodes,
	SickBeardCommandEpisode,
	SickBeardCommandEpisodeSearch,
	SickBeardCommandEpisodeSetStatus,
	
	// history commands
	SickBeardCommandHistory,
	SickBeardCommandHistoryClear,
	SickBeardCommandHistoryTrim,
	SickBeardCommandViewLogs,
	
	// season commands
	SickBeardCommandSeasonList,
	SickBeardCommandSeasons,
	
	// show commands
	SickBeardCommandShow,
	SickBeardCommandShowAddExisting,
	SickBeardCommandShowAddNew,
	SickBeardCommandShowCache,
	SickBeardCommandShowDelete,
	SickBeardCommandShowGetQuality,
	SickBeardCommandShowRefresh,
	SickBeardCommandShowSetQuality,
	SickBeardCommandShowStatus,
	SickBeardCommandShowUpdate,
	SickBeardCommandShowGetPoster,
	SickBeardCommandShowGetBanner,
	SickBeardCommandShows,
	SickBeardCommandShowsStats,
} SickBeardCommand;

@interface SBGlobal : NSObject

+ (OrderedDictionary*)validLanguages;
+ (OrderedDictionary*)initialQualities;
+ (OrderedDictionary*)archiveQualities;
+ (OrderedDictionary*)statuses;

+ (NSArray*)qualitiesAsCodes:(NSArray*)qualities;
+ (NSArray*)qualitiesFromCodes:(NSArray*)codes;

+ (NSString*)feedbackBody;

@end
