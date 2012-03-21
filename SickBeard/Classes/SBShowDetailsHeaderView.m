//
//  SBShowDetailsHeaderView.m
//  SickBeard
//
//  Created by Colin Humber on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBShowDetailsHeaderView.h"
#import "SBCellBackground.h"

@implementation SBShowDetailsHeaderView

@synthesize backgroundView;
@synthesize showImageView;
@synthesize showNameLabel;
@synthesize statusLabel;
@synthesize networkLabel;
@synthesize episodeCountLabel;
@synthesize progressBar;

- (void)awakeFromNib {
	self.progressBar.borderColor = RGBCOLOR(72, 34, 13);
	self.progressBar.barColor = RGBCOLOR(72, 34, 13);
	self.progressBar.backgroundColor = [UIColor clearColor];
	
	self.showImageView.initialImage = [UIImage imageNamed:@"placeholder"];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
