//
//  SBShow.m
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBShow.h"

@implementation SBShow

@synthesize tvdbID;
@synthesize airByDate;
@synthesize hasBannerCached;
@synthesize hasPosterCached;
@synthesize languageCode;
@synthesize isPaused;
@synthesize quality;
@synthesize showName;
@synthesize bannerUrlPath;
@synthesize posterUrlPath;

- (id)initWithDictionary:(NSDictionary*)dict {
	self = [super init];
	
	if (self) {
		self.airByDate = [[dict objectForKey:@"airs_by_date"] boolValue];
		self.hasBannerCached = [[[dict objectForKey:@"cache"] objectForKey:@"banner"] boolValue];
		self.hasPosterCached = [[[dict objectForKey:@"cache"] objectForKey:@"poster"] boolValue];
		self.languageCode = [dict objectForKey:@"language"];
		self.isPaused = [[dict objectForKey:@"paused"] boolValue];
		
		NSString *qualityString = [dict objectForKey:@"quality"];
		if ([qualityString isEqualToString:@"HD"]) {
			self.quality = ShowQualityHD;
		}
		else if ([qualityString isEqualToString:@"SD"]) {
			self.quality = ShowQualitySD;
		}
		else {
			self.quality = ShowQualityUnknown;
		}
		
		self.showName = [dict objectForKey:@"show_name"];
	}
	
	return self;
}

+ (id)itemWithDictionary:(NSDictionary*)dict {
	return [[self alloc] initWithDictionary:dict];
}

- (NSString*)bannerUrlPath {
	return [NSString stringWithFormat:@"showPoster/?show=%@&which=banner", self.tvdbID];
}

- (NSString*)posterUrlPath {
	return [NSString stringWithFormat:@"showPoster/?show=%@&which=poster", self.tvdbID];
}


@end
