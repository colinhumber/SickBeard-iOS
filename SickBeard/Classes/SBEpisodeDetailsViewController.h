//
//  SBEpisodeDetailsViewController.h
//  SickBeard
//
//  Created by Colin Humber on 9/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBBaseViewController.h"

@class SBEpisode;
@class SBSectionHeaderView;
@class SBCellBackground;
@class SBEpisodeDetailsHeaderView;
@protocol SBEpisodeDetailsDataSource;

@interface SBEpisodeDetailsViewController : SBBaseViewController <UIActionSheetDelegate> {
	BOOL _isTransitioning;
}

- (IBAction)swipeLeft:(id)sender;
- (IBAction)swipeRight:(id)sender;

@property (nonatomic, strong) IBOutlet SBEpisodeDetailsHeaderView *currentHeaderView;
@property (nonatomic, strong) IBOutlet SBEpisodeDetailsHeaderView *nextHeaderView;
@property (nonatomic, strong) IBOutlet SBCellBackground *headerContainerView;
@property (nonatomic, strong) IBOutlet UIView *containerView;

@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *showPosterImageView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) SBEpisode *episode;
@property (nonatomic, strong) IBOutlet SBSectionHeaderView *headerView;
@property (nonatomic, strong) IBOutlet SBCellBackground *episodeDescriptionBackground;

@property (nonatomic, weak) id<SBEpisodeDetailsDataSource> dataSource;

@end


@protocol SBEpisodeDetailsDataSource <NSObject>

- (SBEpisode*)nextEpisode;
- (SBEpisode*)previousEpisode;

@property (nonatomic, strong) NSIndexPath *currentEpisodeIndexPath;

@end