//
//  SBEpisode.h
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DictionaryCreation.h"
#import "SBBaseEpisode.h"

@class SBShow;

@interface SBEpisode : SBBaseEpisode <DictionaryCreation>

//@property (nonatomic, strong) NSDate *airDate;
//@property (nonatomic, strong) NSString *episodeDescription;
@property (nonatomic, strong) NSString *location;
//@property (nonatomic, strong) NSString *name;
@property (nonatomic) EpisodeStatus status;
//@property (nonatomic) int season;
//@property (nonatomic) int number;
//@property (nonatomic, strong) SBShow *show;



@end
