//
//  NSUserDefaults+SickBeard.m
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSUserDefaults+SickBeard.h"
#import "SBServer.h"

NSString *const DefaultsRegisteredKey = @"DefaultsRegisteredKey";

NSString *const ServerHasBeenSetupKey = @"server_has_been_setup_key";
NSString *const ServerKey = @"server_key";

NSString *const InitialQualitiesKey = @"initial_qualities_key";
NSString *const ArchiveQualitiesKey = @"archive_qualities_key";
NSString *const UseSeasonFoldersKey = @"use_season_folders_key";
NSString *const StatusKey = @"status_key";

@implementation NSUserDefaults (SickBeard)

- (BOOL)getDefaultsRegistered {
	return [self boolForKey:DefaultsRegisteredKey];
}

- (void)setDefaultsRegistered:(BOOL)val {
	[self setBool:val forKey:DefaultsRegisteredKey];
}

- (BOOL)getServerHasBeenSetup {
	return [self boolForKey:ServerHasBeenSetupKey];
}

- (void)setServerHasBeenSetup:(BOOL)val {
	[self setBool:val forKey:ServerHasBeenSetupKey];
}

- (SBServer*)getServer {
	NSData *data = [self objectForKey:ServerKey];
	if (data) {
		return [NSKeyedUnarchiver unarchiveObjectWithData:data];
	}
	
	return nil;
}

- (void)setServer:(SBServer*)val {
	[self setObject:[NSKeyedArchiver archivedDataWithRootObject:val] forKey:ServerKey];
	[self synchronize];
}

// initial qualities
- (NSMutableArray*)getInitialQualities {
	NSArray *iq = [self objectForKey:InitialQualitiesKey];
	
	if (!iq) {
		iq = [NSArray array];
	}
	
	return [[iq mutableCopy] autorelease];
}

- (void)setInitialQualities:(NSMutableArray *)initialQualities {
	[self setObject:initialQualities forKey:InitialQualitiesKey];
}

// archive qualities
- (NSMutableArray*)getArchiveQualities {
	NSArray *aq = [self objectForKey:ArchiveQualitiesKey];
	
	if (!aq) {
		aq = [NSArray array];
	}
	
	return [[aq mutableCopy] autorelease];
}

- (void)setArchiveQualities:(NSMutableArray *)archiveQualities {
	[self setObject:archiveQualities forKey:ArchiveQualitiesKey];
}

// status
- (NSString*)getStatus {
	return [self stringForKey:StatusKey];
}

- (void)setStatus:(NSString *)status {
	[self setObject:status forKey:StatusKey];
}

// season folders
- (BOOL)getUseSeasonFolders {
	return [self boolForKey:UseSeasonFoldersKey];
}

- (void)setUseSeasonFolders:(BOOL)val {
	[self setBool:val forKey:UseSeasonFoldersKey];
}


@end
