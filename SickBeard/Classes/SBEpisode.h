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

@interface SBEpisode : SBBaseEpisode <DictionaryCreation>
@property (nonatomic, strong) NSString *location;
@property (nonatomic) EpisodeStatus status;
@end
