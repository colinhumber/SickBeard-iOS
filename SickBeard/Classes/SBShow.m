//
//  SBShow.m
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBShow.h"
#import "NSDate+Utilities.h"

@implementation SBShow

@synthesize tvdbID;
@synthesize tvRageID;
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
		if ([qualityString rangeOfString:@"HD"].location != NSNotFound) {
			self.quality = ShowQualityHD;
		}
		else if ([qualityString rangeOfString:@"SD"].location != NSNotFound) {
			self.quality = ShowQualitySD;
		}
		else if ([qualityString rangeOfString:@"Custom"].location != NSNotFound) {
			self.quality = ShowQualityCustom;
		}
		else {
			self.quality = ShowQualityUnknown;
		}
		
		NSString *stat = [[dict objectForKey:@"status"] lowercaseString];
		
		if ([stat isEqualToString:@"continuing"]) {
			self.status = ShowStatusContinuing;
		}
		else if ([stat isEqualToString:@"ended"]) {
			self.status = ShowStatusEnded;
		}
		else {
			self.status = ShowStatusUnknown;
		}
		
		self.tvdbID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"tvdbid"]];
		self.tvRageID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"tvrage_id"]];
		self.showName = [dict objectForKey:@"tvrage_name"];
		self.network = [dict objectForKey:@"network"];
		self.nextEpisodeDate = [NSDate dateWithString:[dict objectForKey:@"next_ep_airdate"]];
	}
	
	return self;
}

+ (id)itemWithDictionary:(NSDictionary*)dict {
	return [[self alloc] initWithDictionary:dict];
}

- (NSString*)description {
	return [NSString stringWithFormat:@"<%@ = %8@ | name = %@ | network = %@ | status = %d>", [self class], self, showName, network, status];
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
		
		NSString *sanitized = [[self.showName stringByReplacingOccurrencesOfString:foundData withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		return sanitized;
	}

	return self.showName;
}

+ (NSString*)showStatusAsString:(ShowStatus)status {
	switch (status) {
		case ShowStatusContinuing:
			return NSLocalizedString(@"Continuing", @"Continuing");
			
		case ShowStatusEnded:
			return NSLocalizedString(@"Ended", @"Ended");
			
		default:
			return NSLocalizedString(@"Unknown", @"Unknown");
	}
}

+ (NSString*)showQualityAsString:(ShowQuality)quality {
	switch (quality) {
		case ShowQualityHD:
			return NSLocalizedString(@"HD", @"HD");
			
		case ShowQualitySD:
			return NSLocalizedString(@"SD", @"SH");
			
		case ShowQualityCustom:
			return NSLocalizedString(@"Custom", @"Custom");
			
		default:
			return NSLocalizedString(@"Unknown", @"Unknown");
	}
}


@end
