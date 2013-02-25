//
//  SBShowDetailsHeaderView.h
//  SickBeard
//
//  Created by Colin Humber on 12/12/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDHUDProgressBar.h"

@class SBCellBackground;

@interface SBShowDetailsHeaderView : UIView

@property (nonatomic, strong) IBOutlet SBCellBackground *backgroundView;
@property (nonatomic, strong) IBOutlet NINetworkImageView *showImageView;
@property (nonatomic, strong) IBOutlet UILabel *showNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *networkLabel;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UILabel *episodeCountLabel;
@property (nonatomic, strong) IBOutlet TDHUDProgressBar *progressBar;

@end
