//
//  NSUserDefaults+SickBeard.h
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBServer;

extern NSString *const DefaultsRegisteredKey;

extern NSString *const ServerHasBeenSetupKey;
extern NSString *const ServerKey;

extern NSString *const InitialQualitiesKey;
extern NSString *const ArchiveQualitiesKey;
extern NSString *const UseSeasonFoldersKey;
extern NSString *const StatusKey;


@interface NSUserDefaults (SickBeard)

@property (assign, getter=getDefaultsRegistered, setter=setDefaultsRegistered:) BOOL defaultsRegistered;

@property (assign, getter=getServerHasBeenSetup, setter=setServerHasBeenSetup:) BOOL serverHasBeenSetup;
@property (assign, getter=getServer, setter=setServer:) SBServer *server;

@property (assign, getter=getInitialQualities, setter=setInitialQualities:) NSMutableArray *initialQualities;
@property (assign, getter=getArchiveQualities, setter=setArchiveQualities:) NSMutableArray *archiveQualities;
@property (assign, getter=getStatus, setter=setStatus:) NSString *status;
@property (assign, getter=getUseSeasonFolders, setter=setUseSeasonFolders:) BOOL useSeasonFolders;


@end
