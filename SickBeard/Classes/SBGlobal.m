//
//  SBGlobal.m
//  SickBeard
//
//  Created by Colin Humber on 8/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBGlobal.h"

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

@end
