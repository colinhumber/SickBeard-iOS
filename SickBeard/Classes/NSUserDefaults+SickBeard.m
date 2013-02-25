//
//  NSUserDefaults+SickBeard.m
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "NSUserDefaults+SickBeard.h"
#import "SBServer.h"
#import "SBRootDirectory.h"

NSString *const SBDefaultsRegisteredKey = @"SBDefaultsRegisteredKey";

NSString *const SBServerHasBeenSetupKey = @"SBServerHasBeenSetupKey";
NSString *const SBServerKey = @"SBServerKey";
NSString *const SBTemporaryServerKey = @"SBTemporaryServerKey";
NSString *const SBDefaultDirectoriesKey = @"SBDefaultDirectoriesKey";
NSString *const SBDefaultDirectoryIndexKey = @"SBDefaultDirectoryIndexKey";
NSString *const SBShouldUpdateShowList = @"SBShouldUpdateShowList";


NSString *const SBInitialQualitiesKey = @"SBInitialQualitiesKey";
NSString *const SBArchiveQualitiesKey = @"SBArchiveQualitiesKey";
NSString *const SBUseSeasonFoldersKey = @"SBUseSeasonFoldersKey";
NSString *const SBStatusKey = @"SBStatusKey";

@implementation NSUserDefaults (SickBeard)

#pragma mark - Defaults
- (BOOL)getDefaultsRegistered {
	return [self boolForKey:SBDefaultsRegisteredKey];
}

- (void)setDefaultsRegistered:(BOOL)val {
	[self setBool:val forKey:SBDefaultsRegisteredKey];
}

#pragma mark - Server
- (BOOL)getServerHasBeenSetup {
	return [self boolForKey:SBServerHasBeenSetupKey];
}

- (void)setServerHasBeenSetup:(BOOL)val {
	[self setBool:val forKey:SBServerHasBeenSetupKey];
}

- (SBServer*)getServer {
	NSData *data = [self objectForKey:SBServerKey];
	if (data) {
		return [NSKeyedUnarchiver unarchiveObjectWithData:data];
	}
	
	return nil;
}

- (void)setServer:(SBServer*)val {
	[self setObject:[NSKeyedArchiver archivedDataWithRootObject:val] forKey:SBServerKey];
	[self synchronize];
}

- (SBServer*)getTemporaryServer {
	NSData *data = [self objectForKey:SBTemporaryServerKey];
	if (data) {
		return [NSKeyedUnarchiver unarchiveObjectWithData:data];
	}
	
	return nil;
}

- (void)setTemporaryServer:(SBServer*)val {
	[self setObject:[NSKeyedArchiver archivedDataWithRootObject:val] forKey:SBTemporaryServerKey];
	[self synchronize];
}

- (NSArray*)getDefaultDirectories {
	NSData *data = [self objectForKey:SBDefaultDirectoriesKey];
	
	if (data) {
		return [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
	}
	
	return [NSMutableArray array];
}

- (void)setDefaultDirectories:(NSArray *)defaultDirectories {
	[self setObject:[NSKeyedArchiver archivedDataWithRootObject:defaultDirectories] forKey:SBDefaultDirectoriesKey];
}

- (SBRootDirectory*)defaultDirectory {
	return [self.defaultDirectories find:^BOOL(SBRootDirectory *dir) {
		return dir.isDefault;
	}];
}

- (void)setShouldUpdateShowList:(BOOL)v {
	[self setBool:v forKey:SBShouldUpdateShowList];
}

- (BOOL)getShouldUpdateShowList {
	return [self boolForKey:SBShouldUpdateShowList];
}

#pragma mark - Settings
- (NSMutableArray*)getInitialQualities {
	NSArray *iq = [self objectForKey:SBInitialQualitiesKey];
	
	if (!iq) {
		iq = [NSArray array];
	}
	
	return [iq mutableCopy];
}

- (void)setInitialQualities:(NSMutableArray *)initialQualities {
	[self setObject:initialQualities forKey:SBInitialQualitiesKey];
}

// archive qualities
- (NSMutableArray*)getArchiveQualities {
	NSArray *aq = [self objectForKey:SBArchiveQualitiesKey];
	
	if (!aq) {
		aq = [NSArray array];
	}
	
	return [aq mutableCopy];
}

- (void)setArchiveQualities:(NSMutableArray *)archiveQualities {
	[self setObject:archiveQualities forKey:SBArchiveQualitiesKey];
}

// status
- (NSString*)getStatus {
	return [self stringForKey:SBStatusKey];
}

- (void)setStatus:(NSString *)status {
	[self setObject:status forKey:SBStatusKey];
}

// season folders
- (BOOL)getUseSeasonFolders {
	return [self boolForKey:SBUseSeasonFoldersKey];
}

- (void)setUseSeasonFolders:(BOOL)val {
	[self setBool:val forKey:SBUseSeasonFoldersKey];
}


@end
