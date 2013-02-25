//
//  SBComingEpisode.h
//  SickBeard
//
//  Created by Colin Humber on 9/2/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "DictionaryCreation.h"
#import "SBBaseEpisode.h"

@interface SBComingEpisode : SBBaseEpisode <DictionaryCreation>

//@property (nonatomic, strong) NSDate *airDate;
@property (nonatomic, strong) NSString *airs;
@property (nonatomic, strong) NSString *name;
//@property (nonatomic, strong) NSString *plot;
//@property (nonatomic, strong) NSString *network;
//@property (nonatomic, strong) NSString *quality;
//@property (nonatomic, assign) int season;
//@property (nonatomic, assign) int number;
//@property (nonatomic, strong) NSString *showName;
//@property (nonatomic, strong) NSString *showStatus;
//@property (nonatomic, strong) NSString *tvdbID;
@property (nonatomic, strong) NSString *weekday;

@end
