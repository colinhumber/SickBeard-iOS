//
//  SBITunesUrlCache.m
//  SickBeard
//
//  Created by Colin Humber on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBITunesUrlCache.h"

#define kSBImageURLCache @"SBImageURLCache"
#define kSBImageURLCacheFile @"imageUrlCache.plist"

@implementation SBITunesUrlCache

+ (SBITunesUrlCache*)sharedCache {
	static SBITunesUrlCache *_sharedCache = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedCache = [[SBITunesUrlCache alloc] init];	
	});
	
	return _sharedCache;
}

- (id)init {
	if (self = [super init]) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		_diskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kSBImageURLCache];
	
		NSFileManager *fm = [NSFileManager defaultManager];
		if (![fm fileExistsAtPath:_diskCachePath]) {
            [fm createDirectoryAtPath:_diskCachePath
		  withIntermediateDirectories:YES
						   attributes:nil
								error:NULL];
        }
		
		_cacheFile = [_diskCachePath stringByAppendingPathComponent:kSBImageURLCacheFile];
		if ([fm fileExistsAtPath:_cacheFile]) {
			internal = [[NSDictionary dictionaryWithContentsOfFile:_cacheFile] mutableCopy];
		}
		else {
			internal = [[NSMutableDictionary alloc] init];
		}
	}
	
	return self;
}

- (void)setImageUrlPath:(NSString*)urlPath forKey:(NSString*)key {
	NSArray *keys = [internal allKeys];
	
	if (![keys containsObject:key]) {
		[internal setObject:urlPath forKey:key];
	}
}

- (NSString*)imageUrlPathForKey:(NSString*)key {
	return [internal objectForKey:key];
}

- (void)save {
	[internal writeToFile:_cacheFile atomically:NO];
}


@end
