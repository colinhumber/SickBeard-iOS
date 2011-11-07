//
//  SBComingEpisode.h
//  SickBeard
//
//  Created by Colin Humber on 9/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DictionaryCreation.h"

@interface SBComingEpisode : NSObject <DictionaryCreation>

@property (nonatomic, strong) NSDate *airDate;
@property (nonatomic, copy) NSString *airs;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *network;
@property (nonatomic, copy) NSString *quality;
@property (nonatomic, assign) int season;
@property (nonatomic, assign) int number;
@property (nonatomic, copy) NSString *showName;
@property (nonatomic, copy) NSString *showStatus;
@property (nonatomic, copy) NSString *tvdbID;
@property (nonatomic, copy) NSString *weekday;
@property (nonatomic, readonly) NSString *bannerUrlPath;
@property (nonatomic, readonly) NSString *posterUrlPath;

@end
