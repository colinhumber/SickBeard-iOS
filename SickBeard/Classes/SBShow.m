//
//  SBShow.m
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBShow.h"
#import "NSDate+Utilities.h"

@implementation SBShow

@synthesize tvdbID;
@synthesize airByDate;
@synthesize hasBannerCached;
@synthesize hasPosterCached;
@synthesize languageCode;
@synthesize isPaused;
@synthesize quality;
@synthesize showName;
@synthesize network;
@synthesize status;
@synthesize nextEpisodeDate;
@synthesize sanitizedShowName;

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
		
		self.tvdbID = [dict objectForKey:@"tvdbid"];
		self.showName = [dict objectForKey:@"tvrage_name"];
		self.network = [dict objectForKey:@"network"];
		self.status = [dict objectForKey:@"status"];
		self.nextEpisodeDate = [NSDate dateWithString:[dict objectForKey:@"next_ep_airdate"]];
	}
	
	return self;
}

+ (id)itemWithDictionary:(NSDictionary*)dict {
	return [[self alloc] initWithDictionary:dict];
}

- (NSString*)description {
	return [NSString stringWithFormat:@"<%@ = %08X | name = %@ | network = %@ | status = %@>", [self class], self, showName, network, status];
}

- (NSString*)sanitizedShowName {
	if ([self.showName rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"()"]].location != NSNotFound) {
		NSString *foundData = @"";
		int left, right;

		NSScanner *scanner = [NSScanner scannerWithString:self.showName];
		[scanner scanUpToString:@"(" intoString:nil];
		left = [scanner scanLocation];
		
		[scanner scanUpToString:@")" intoString:nil];
		right = [scanner scanLocation] + 1;
		
		foundData = [self.showName substringWithRange:NSMakeRange(left, (right - left))];

		return [self.showName stringByReplacingOccurrencesOfString:foundData withString:@""];
	}

	return self.showName;
}


@end
