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
		langs[@"Chinese"] = @"zh";
		langs[@"Croatian"] = @"hr";
		langs[@"Czech"] = @"cs";
		langs[@"Danish"] = @"da"; 
		langs[@"Dutch"] = @"nl"; 
		langs[@"English"] = @"en"; 
		langs[@"Finnish"] = @"fi"; 
		langs[@"French"] = @"fr"; 
		langs[@"German"] = @"de"; 
		langs[@"Greek"] = @"el"; 
		langs[@"Hebrew"] = @"he"; 
		langs[@"Hungarian"] = @"hu"; 
		langs[@"Italian"] = @"it"; 
		langs[@"Japanese"] = @"ja"; 
		langs[@"Korean"] = @"ko"; 
		langs[@"Norweigan"] = @"no"; 
		langs[@"Polish"] = @"pl"; 
		langs[@"Portuguese"] = @"pt"; 
		langs[@"Russian"] = @"ru";
		langs[@"Slovenian"] = @"sl";
		langs[@"Spanish"] = @"es";
		langs[@"Swedish"] = @"sv";
		langs[@"Turkish"] = @"tr";
	}
	
	return langs;
}

+ (OrderedDictionary*)initialQualities {
	static OrderedDictionary *qualities = nil;
	
	if (!qualities) {
		qualities = [[OrderedDictionary alloc] init];
		qualities[@"SD TV"] = @"sdtv";
		qualities[@"SD DVD"] = @"sddvd";
		qualities[@"HD TV"] = @"hdtv";
		qualities[@"Raw HD TV"] = @"rawhdtv";
		qualities[@"720p WEB-DL"] = @"hdwebdl";
		qualities[@"720p BluRay"] = @"hdbluray";
		qualities[@"1080p BluRay"] = @"fullhdbluray";
		qualities[@"1080p WEB-DL"] = @"fullhdwebdl";
		qualities[@"1080p HD TV"] = @"fullhdtv";
		qualities[@"Unknown"] = @"unknown";
		qualities[@"Any"] = @"any";
	}
	
	return qualities;
}

+ (OrderedDictionary*)archiveQualities {
	static OrderedDictionary *qualities = nil;
	
	if (!qualities) {
		qualities = [[OrderedDictionary alloc] init];
		qualities[@"SD DVD"] = @"sddvd";
		qualities[@"HD TV"] = @"hdtv";
		qualities[@"Raw HD TV"] = @"rawhdtv";
		qualities[@"720p WEB-DL"] = @"hdwebdl";
		qualities[@"720p BluRay"] = @"hdbluray";
		qualities[@"1080p BluRay"] = @"fullhdbluray";
		qualities[@"1080p WEB-DL"] = @"fullhdwebdl";
		qualities[@"1080p HD TV"] = @"fullhdtv";
		qualities[@"Unknown"] = @"unknown";
		qualities[@"Any"] = @"any";
	}
	
	return qualities;
}

+ (OrderedDictionary*)statuses {
	static OrderedDictionary *statuses = nil;
	
	if (!statuses) {
		statuses = [[OrderedDictionary alloc] init];
		statuses[@"Skipped"] = @"skipped";
		statuses[@"Wanted"] = @"wanted";
		statuses[@"Archived"] = @"archived";
		statuses[@"Ignored"] = @"ignored";
	}
	
	return statuses;
}

+ (NSArray*)qualitiesAsCodes:(NSArray*)qualities {
	NSDictionary *dict = [self initialQualities];
	NSMutableArray *list = [NSMutableArray array];
	
	for (NSString *quality in qualities) {
		[list addObject:dict[quality]];
	}
	
	return list;
}

+ (NSArray*)qualitiesFromCodes:(NSArray*)codes {
	NSDictionary *dict = [self initialQualities];
	NSMutableArray *list = [NSMutableArray array];
	
	for (NSString *code in codes) {
		NSArray *keys = [dict allKeysForObject:code];
		if (keys.count > 0) {
			[list addObject:keys[0]];
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
	[string appendFormat:@"App Name: %@\n", info[@"CFBundleDisplayName"]];
	[string appendFormat:@"Version: %@ (%@)\n", info[@"CFBundleShortVersionString"], info[@"CFBundleVersion"]];
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
		[(NSMutableArray*)unsortedSections[index] addObject:object];
	}
	
	NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
	
	// sort each section
	for (NSMutableArray *section in unsortedSections) {
		[sections addObject:[[collation sortedArrayFromArray:section collationStringSelector:selector] mutableCopy]];
	}
	
	return sections;
}


@end
