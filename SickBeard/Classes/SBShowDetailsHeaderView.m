//
//  SBShowDetailsHeaderView.m
//  SickBeard
//
//  Created by Colin Humber on 12/12/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBShowDetailsHeaderView.h"
#import "SBCellBackground.h"

@implementation SBShowDetailsHeaderView

- (void)awakeFromNib {
	self.progressBar.borderColor = RGBCOLOR(97, 77, 52);
	self.progressBar.barColor = RGBCOLOR(97, 77, 52);
	self.progressBar.backgroundColor = [UIColor clearColor];
	
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
