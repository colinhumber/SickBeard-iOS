//
//  SBShowDetailsHeaderView.h
//  SickBeard
//
//  Created by Colin Humber on 12/12/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBShowDetailsHeaderView : UIView

@property (nonatomic, weak, readonly) UIImageView *showImageView;
@property (nonatomic, weak, readonly) UILabel *showNameLabel;
@property (nonatomic, weak, readonly) UILabel *networkLabel;
@property (nonatomic, weak, readonly) UILabel *statusLabel;
@property (nonatomic, weak, readonly) UILabel *episodeCountLabel;

@end
