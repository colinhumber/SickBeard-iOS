//
//  SBShowDetailsHeaderView.m
//  SickBeard
//
//  Created by Colin Humber on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBShowDetailsHeaderView.h"

@implementation SBShowDetailsHeaderView

@synthesize showImageView;
@synthesize showNameLabel;
@synthesize networkLabel;
@synthesize episodeCountLabel;
@synthesize progressBar;

- (void)awakeFromNib {
	self.progressBar.borderColor = [UIColor whiteColor];
	self.progressBar.barColor = [UIColor whiteColor];
	self.progressBar.backgroundColor = [UIColor clearColor];
	
	self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture"]];
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
