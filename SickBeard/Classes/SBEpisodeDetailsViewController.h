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

@interface SBEpisodeDetailsViewController : SBBaseViewController <UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *airDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *seasonLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *showPosterImageView;
@property (nonatomic, strong) SBEpisode *episode;

@end
