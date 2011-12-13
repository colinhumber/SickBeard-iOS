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
@class SBEpisodeDetailsHeaderView;
@protocol SBEpisodeDetailsDataSource;

@interface SBEpisodeDetailsViewController : SBBaseViewController <UIActionSheetDelegate> {
	BOOL _isTransitioning;
}

- (IBAction)swipeLeft:(id)sender;
- (IBAction)swipeRight:(id)sender;

@property (nonatomic, strong) IBOutlet SBEpisodeDetailsHeaderView *currentHeaderView;
@property (nonatomic, strong) IBOutlet SBEpisodeDetailsHeaderView *nextHeaderView;
@property (nonatomic, strong) IBOutlet UIView *headerContainerView;

@property (strong, nonatomic) IBOutlet UILabel *episodeSummaryLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *showPosterImageView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) SBEpisode *episode;
@property (nonatomic, weak) id<SBEpisodeDetailsDataSource> dataSource;

@end


@protocol SBEpisodeDetailsDataSource <NSObject>

- (SBEpisode*)nextEpisode;
- (SBEpisode*)previousEpisode;

@property (nonatomic, strong) NSIndexPath *currentEpisodeIndexPath;

@end