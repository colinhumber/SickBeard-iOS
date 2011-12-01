//
//  SBITunesUrlCache.h
//  SickBeard
//
//  Created by Colin Humber on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBITunesUrlCache : NSObject {
	NSMutableDictionary *internal;
	NSString *_diskCachePath;
	NSString *_cacheFile;
}

+ (SBITunesUrlCache*)sharedCache;

- (void)setImageUrlPath:(NSString*)urlPath forKey:(NSString*)key;
- (NSString*)imageUrlPathForKey:(NSString*)key;
- (void)save;

@end
