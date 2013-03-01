//
//  SBGlobal.m
//  SickBeard
//
//  Created by Colin Humber on 8/29/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBGlobal.h"
#import "GTMNSString+URLArguments.h"

NSString *const SBServerURLDidChangeNotification = @"SBServerURLDidChangeNotification";

@implementation SBGlobal

+ (OrderedDictionary*)validLanguages {
	static OrderedDictionary *langs = nil;
	
	if (!langs) {
		langs = [[OrderedDictionary alloc] init];
		[langs setObject:@"zh" forKey:@"Chinese"];
		[langs setObject:@"hr" forKey:@"Croatian"];
		[langs setObject:@"cs" forKey:@"Czech"];
		[langs setObject:@"da" forKey:@"Danish"]; 
		[langs setObject:@"nl" forKey:@"Dutch"]; 
		[langs setObject:@"en" forKey:@"English"]; 
		[langs setObject:@"fi" forKey:@"Finnish"]; 
		[langs setObject:@"fr" forKey:@"French"]; 
		[langs setObject:@"de" forKey:@"German"]; 
		[langs setObject:@"el" forKey:@"Greek"]; 
		[langs setObject:@"he" forKey:@"Hebrew"]; 
		[langs setObject:@"hu" forKey:@"Hungarian"]; 
		[langs setObject:@"it" forKey:@"Italian"]; 
		[langs setObject:@"ja" forKey:@"Japanese"]; 
		[langs setObject:@"ko" forKey:@"Korean"]; 
		[langs setObject:@"no" forKey:@"Norweigan"]; 
		[langs setObject:@"pl" forKey:@"Polish"]; 
		[langs setObject:@"pt" forKey:@"Portuguese"]; 
		[langs setObject:@"ru" forKey:@"Russian"];
		[langs setObject:@"sl" forKey:@"Slovenian"];
		[langs setObject:@"es" forKey:@"Spanish"];
		[langs setObject:@"sv" forKey:@"Swedish"];
		[langs setObject:@"tr" forKey:@"Turkish"];
	}
	
	return langs;
}

+ (OrderedDictionary*)initialQualities {
	static OrderedDictionary *qualities = nil;
	
	if (!qualities) {
		qualities = [[OrderedDictionary alloc] init];
		[qualities setObject:@"sdtv" forKey:@"SD TV"];
		[qualities setObject:@"sddvd" forKey:@"SD DVD"];
		[qualities setObject:@"hdtv" forKey:@"HD TV"];
		[qualities setObject:@"hdwebdl" forKey:@"720p WEB-DL"];
		[qualities setObject:@"hdbluray" forKey:@"720p BluRay"];
		[qualities setObject:@"fullhdbluray" forKey:@"1080p BluRay"];
		[qualities setObject:@"unknown" forKey:@"Unknown"];
		[qualities setObject:@"any" forKey:@"Any"];
	}
	
	return qualities;
}

+ (OrderedDictionary*)archiveQualities {
	static OrderedDictionary *qualities = nil;
	
	if (!qualities) {
		qualities = [[OrderedDictionary alloc] init];
		[qualities setObject:@"sddvd" forKey:@"SD DVD"];
		[qualities setObject:@"hdtv" forKey:@"HD TV"];
		[qualities setObject:@"hdwebdl" forKey:@"720p WEB-DL"];
		[qualities setObject:@"hdbluray" forKey:@"720p BluRay"];
		[qualities setObject:@"fullhdbluray" forKey:@"1080p BluRay"];
		[qualities setObject:@"unknown" forKey:@"Unknown"];
		[qualities setObject:@"any" forKey:@"Any"];
	}
	
	return qualities;
}

+ (OrderedDictionary*)statuses {
	static OrderedDictionary *statuses = nil;
	
	if (!statuses) {
		statuses = [[OrderedDictionary alloc] init];
		[statuses setObject:@"skipped" forKey:@"Skipped"];
		[statuses setObject:@"wanted" forKey:@"Wanted"];
		[statuses setObject:@"archived" forKey:@"Archived"];
		[statuses setObject:@"ignored" forKey:@"Ignored"];
	}
	
	return statuses;
}

+ (NSArray*)qualitiesAsCodes:(NSArray*)qualities {
	NSDictionary *dict = [self initialQualities];
	NSMutableArray *list = [NSMutableArray array];
	
	for (NSString *quality in qualities) {
		[list addObject:[dict objectForKey:quality]];
	}
	
	return list;
}

+ (NSArray*)qualitiesFromCodes:(NSArray*)codes {
	NSDictionary *dict = [self initialQualities];
	NSMutableArray *list = [NSMutableArray array];
	
	for (NSString *code in codes) {
		NSArray *keys = [dict allKeysForObject:code];
		if (keys.count > 0) {
			[list addObject:[keys objectAtIndex:0]];
		}
	}
	
	return list;
}

+ (NSString*)feedbackBody {
	NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
	UIDevice *device = [UIDevice currentDevice];
	
	NSMutableString *string = [NSMutableString string];
	[string appendString:@"\n\n==================\n"];
	[string appendString:@"Please leave the following information in the email as it will help us debug any issues.\n"];
	[string appendFormat:@"App Name: %@\n", [info objectForKey:@"CFBundleDisplayName"]];
	[string appendFormat:@"Version: %@ (%@)\n", [info	objectForKey:@"CFBundleShortVersionString"], [info objectForKey:@"CFBundleVersion"]];
	[string appendFormat:@"Model: %@\n", device.model];
	[string appendFormat:@"OS Version: %@ %@\n", device.systemName, device.systemVersion];
	
	return string;
}

+ (NSString*)itunesLinkForShow:(NSString*)showName {		
	return [NSString stringWithFormat:@"itms://phobos.apple.com/WebObjects/MZSearch.woa/wa/search?term=%@", [showName gtm_stringByEscapingForURLArgument]];
}

+ (NSMutableArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector {
	UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
	
	NSInteger sectionCount = [[collation sectionTitles] count]; //section count is take from sectionTitles and not sectionIndexTitles
	NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
	
	for (int i = 0; i < sectionCount; i++) {
		[unsortedSections addObject:[NSMutableArray array]];
	}
	
	// put each object into a section
	for (id object in array) {
		NSInteger index = [collation sectionForObject:object collationStringSelector:selector];
		[(NSMutableArray*)[unsortedSections objectAtIndex:index] addObject:object];
	}
	
	NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
	
	// sort each section
	for (NSMutableArray *section in unsortedSections) {
		[sections addObject:[[collation sortedArrayFromArray:section collationStringSelector:selector] mutableCopy]];
	}
	
	return sections;
}


@end
