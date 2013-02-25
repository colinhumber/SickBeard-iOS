//
//  SBEmptyView.m
//  SickBeard
//
//  Created by Colin Humber on 12/16/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBEmptyView.h"

@implementation SBEmptyView

@synthesize emptyLabel;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		
		self.emptyLabel = [[UILabel alloc] init];
		emptyLabel.font = [UIFont systemFontOfSize:28];
		emptyLabel.textAlignment = UITextAlignmentCenter;
		emptyLabel.numberOfLines = 0;
		emptyLabel.textColor = RGBCOLOR(76, 54, 40);
		emptyLabel.shadowColor = [UIColor whiteColor];
		emptyLabel.shadowOffset = CGSizeMake(0, 1);
		emptyLabel.backgroundColor = self.backgroundColor;
		emptyLabel.alpha = 0.75;
		[self addSubview:emptyLabel];
	}
	
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	self.emptyLabel.frame = self.bounds;
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
