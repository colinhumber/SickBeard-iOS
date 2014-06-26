//
//  SBGlobal.h
//  SickBeard
//
//  Created by Colin Humber on 8/29/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderedDictionary.h"

#define kTVDBLinkFormat @"http://thetvdb.com/?tab=series&id=%@&lid=7"
#define kTVRageLinkFormat @"http://www.tvrage.com/shows/id-%@"
#define kDonateLink @"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=2QFWVTWEMQRSN"
#define XDELEGATE (SBAppDelegate*)[UIApplication sharedApplication].delegate

#define RGBCOLOR(r, g, b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]
#define RGBACOLOR(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

// posted when the user changes any information about the server. The notification.object sent will be the updates SBServer instance
extern NSString *const SBServerURLDidChangeNotification;

typedef NS_ENUM(NSInteger, SickBeardCommand) {
	// system commands
	SickBeardCommandCheckScheduler = 0,
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
};


@interface SBGlobal : NSObject

+ (OrderedDictionary*)validLanguages;
+ (OrderedDictionary*)initialQualities;
+ (OrderedDictionary*)archiveQualities;
+ (OrderedDictionary*)statuses;

+ (NSArray*)qualitiesAsCodes:(NSArray*)qualities;
+ (NSArray*)qualitiesFromCodes:(NSArray*)codes;

+ (NSString*)feedbackBody;

+ (NSString*)itunesLinkForShow:(NSString*)showName;

+ (NSMutableArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector;

@end
