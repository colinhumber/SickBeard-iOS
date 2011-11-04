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

@property (nonatomic, copy) NSString *tvdbID;
@property (nonatomic, assign) BOOL airByDate;
@property (nonatomic, assign) BOOL hasBannerCached;
@property (nonatomic, assign) BOOL hasPosterCached;
@property (nonatomic, copy) NSString *languageCode;
@property (nonatomic, assign) BOOL isPaused;
@property (nonatomic, assign) ShowQuality quality;
@property (nonatomic, copy) NSString *showName;
@property (weak, nonatomic, readonly) NSString *bannerUrlPath;
@property (weak, nonatomic, readonly) NSString *posterUrlPath;


@end
