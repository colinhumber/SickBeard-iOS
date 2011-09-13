//
//  SBEpisodeDetailsViewController.h
//  SickBeard
//
//  Created by Colin Humber on 9/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBEpisode;

@interface SBEpisodeDetailsViewController : UIViewController <UIActionSheetDelegate>

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *airDateLabel;
@property (retain, nonatomic) IBOutlet UILabel *seasonLabel;
@property (retain, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) SBEpisode *episode;

@end
