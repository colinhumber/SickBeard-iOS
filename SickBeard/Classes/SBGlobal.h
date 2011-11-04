//
//  SBGlobal.h
//  SickBeard
//
//  Created by Colin Humber on 8/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderedDictionary.h"


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
	SickBeardCommandShowSearchTVDB,
	SickBeardCommandShowSetQuality,
	SickBeardCommandShowStatus,
	SickBeardCommandShowUpdate,
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

@end
