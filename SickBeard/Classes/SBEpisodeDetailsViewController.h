//
//  SBEpisodeDetailsViewController.h
//  SickBeard
//
//  Created by Colin Humber on 9/1/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBBaseViewController.h"

@class SBBaseEpisode;
@class SBSectionHeaderView;
@class SBCellBackground;
@class SBEpisodeDetailsHeaderView;
@protocol SBEpisodeDetailsDataSource;

@interface SBEpisodeDetailsViewController : SBBaseViewController

@property (nonatomic, weak) id<SBEpisodeDetailsDataSource> dataSource;
@property (nonatomic, strong) SBBaseEpisode *episode;

@end


@protocol SBEpisodeDetailsDataSource <NSObject>

- (SBBaseEpisode*)nextEpisode;
- (SBBaseEpisode*)previousEpisode;

@property (nonatomic, strong) NSIndexPath *currentEpisodeIndexPath;

@end