//
//  SBShow.h
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DictionaryCreation.h"

typedef enum {
	ShowQualityUnknown,
	ShowQualityHD,
	ShowQualitySD
} ShowQuality;

@interface SBShow : NSObject <DictionaryCreation>

@property (nonatomic, strong) NSString *tvdbID;
@property (nonatomic) BOOL airByDate;
@property (nonatomic) BOOL hasBannerCached;
@property (nonatomic) BOOL hasPosterCached;
@property (nonatomic, strong) NSString *languageCode;
@property (nonatomic) BOOL isPaused;
@property (nonatomic) ShowQuality quality;
@property (nonatomic, strong) NSString *showName;
@property (nonatomic, readonly) NSString *bannerUrlPath;
@property (nonatomic, readonly) NSString *posterUrlPath;


@end
