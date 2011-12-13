//
//  SBSeasonHeaderView.m
//  SickBeard
//
//  Created by Colin Humber on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBSeasonHeaderView.h"

@implementation SBSeasonHeaderView

@synthesize seasonLabel;
@synthesize lightColor;
@synthesize darkColor;

- (id)init {
    self = [super init];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.seasonLabel = [[UILabel alloc] init];
        seasonLabel.textAlignment = UITextAlignmentCenter;
        seasonLabel.opaque = NO;
        seasonLabel.backgroundColor = [UIColor clearColor];
        seasonLabel.font = [UIFont boldSystemFontOfSize:20.0];
        seasonLabel.textColor = [UIColor whiteColor];
        seasonLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        seasonLabel.shadowOffset = CGSizeMake(0, -1);
        [self addSubview:seasonLabel];
		
        self.lightColor = RGBCOLOR(189, 121, 86);
        self.darkColor = RGBCOLOR(71, 36, 12);        
    }
    return self;
}

- (void)layoutSubviews {
	CGFloat coloredBoxMargin = 6.0;
	CGFloat coloredBoxHeight = 40.0;
	
	_coloredBoxRect = CGRectMake(6, 6, self.bounds.size.width - (coloredBoxMargin*2), coloredBoxHeight);
	
	CGFloat paperMargin = 9.0;
	_paperRect = CGRectMake(paperMargin, 
							CGRectGetMaxY(_coloredBoxRect), 
							self.bounds.size.width - (paperMargin*2), 
							self.bounds.size.height - CGRectGetMaxY(_coloredBoxRect));
	self.seasonLabel.frame = _coloredBoxRect;
}


- (void)drawRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGColorRef whiteColor = RGBCOLOR(255, 255, 255).CGColor;
	CGColorRef shadowColor = RGBACOLOR(50, 50, 50, 0.5).CGColor;
		
    CGContextSetFillColorWithColor(ctx, whiteColor);
    CGContextFillRect(ctx, _paperRect);
	
	CGContextSaveGState(ctx);
	CGContextSetShadowWithColor(ctx, CGSizeMake(0, 2), 3.0, shadowColor);
    CGContextSetFillColorWithColor(ctx, self.lightColor.CGColor);
    CGContextFillRect(ctx, _coloredBoxRect);
	CGContextRestoreGState(ctx);
}


@end
