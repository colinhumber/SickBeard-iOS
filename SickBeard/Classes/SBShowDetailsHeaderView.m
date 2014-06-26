//
//  SBShowDetailsHeaderView.m
//  SickBeard
//
//  Created by Colin Humber on 12/12/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBShowDetailsHeaderView.h"

@interface SBShowDetailsHeaderView ()
@property (nonatomic, weak, readwrite) IBOutlet UIImageView *showImageView;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *showNameLabel;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *networkLabel;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *episodeCountLabel;
@end


@implementation SBShowDetailsHeaderView

- (void)awakeFromNib {
	self.showImageView.image = [UIImage imageNamed:@"placeholder"];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
