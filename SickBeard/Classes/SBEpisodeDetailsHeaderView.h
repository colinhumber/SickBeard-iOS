//
//  SBEpisodeDetailsHeaderView.h
//  SickBeard
//
//  Created by Colin Humber on 12/13/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBEpisodeDetailsHeaderView : UIView

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *airDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *seasonLabel;

@end
