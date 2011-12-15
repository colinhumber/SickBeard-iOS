//
//  SBEpisodeDetailsHeaderView.m
//  SickBeard
//
//  Created by Colin Humber on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBEpisodeDetailsHeaderView.h"

@implementation SBEpisodeDetailsHeaderView

@synthesize titleLabel;
@synthesize airDateLabel;
@synthesize seasonLabel;

- (void)commonInit {
	self.backgroundColor = [UIColor clearColor];
	self.opaque = NO;
	
	self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
	self.titleLabel.textColor = RGBCOLOR(107, 73, 20);
	self.titleLabel.textAlignment = UITextAlignmentCenter;
	self.titleLabel.backgroundColor = self.backgroundColor;
	self.titleLabel.shadowColor = RGBACOLOR(255, 255, 255, 0.5);
	self.titleLabel.shadowOffset = CGSizeMake(0, -1);
	self.titleLabel.opaque = NO;
	[self addSubview:self.titleLabel];
	
	self.airDateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	self.airDateLabel.font = [UIFont systemFontOfSize:13];
	self.airDateLabel.textColor = [UIColor blackColor];
	self.airDateLabel.textAlignment = UITextAlignmentCenter;
	self.airDateLabel.backgroundColor = self.backgroundColor;
	self.airDateLabel.opaque = NO;
	[self addSubview:self.airDateLabel];
	
	self.seasonLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	self.seasonLabel.font = [UIFont systemFontOfSize:13];
	self.seasonLabel.textColor = [UIColor blackColor];
	self.seasonLabel.textAlignment = UITextAlignmentCenter;
	self.seasonLabel.backgroundColor = self.backgroundColor;
	self.seasonLabel.opaque = NO;
	[self addSubview:self.seasonLabel];
}


- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		[self commonInit];
	}
	
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self commonInit];
	}
    return self;
}

- (void)layoutSubviews {
	self.titleLabel.frame = CGRectMake(10, 3, 300, 21);
	self.airDateLabel.frame = CGRectMake(20, 23, 280, 21);
	self.seasonLabel.frame = CGRectMake(20, 44, 280, 21);
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
