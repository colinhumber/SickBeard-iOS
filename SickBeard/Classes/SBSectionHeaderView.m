//
//  SBSectionHeaderView.m
//  SickBeard
//
//  Created by Colin Humber on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBSectionHeaderView.h"

@implementation SBSectionHeaderView

@synthesize sectionLabel;
@synthesize lightColor;
@synthesize darkColor;

- (id)init {
    self = [super init];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.sectionLabel = [[UILabel alloc] init];
        sectionLabel.textAlignment = UITextAlignmentCenter;
        sectionLabel.opaque = NO;
        sectionLabel.backgroundColor = [UIColor clearColor];
        sectionLabel.font = [UIFont boldSystemFontOfSize:20.0];
        sectionLabel.textColor = [UIColor whiteColor];
        sectionLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        sectionLabel.shadowOffset = CGSizeMake(0, -1);
        [self addSubview:sectionLabel];
		
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
	self.sectionLabel.frame = _coloredBoxRect;
}


- (void)drawRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	UIColor *shadowColor = RGBACOLOR(50, 50, 50, 0.5);
		
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillRect(ctx, _paperRect);
	
	CGContextSaveGState(ctx);
	CGContextSetShadowWithColor(ctx, CGSizeMake(0, 2), 3.0, shadowColor.CGColor);
    CGContextSetFillColorWithColor(ctx, self.lightColor.CGColor);
    CGContextFillRect(ctx, _coloredBoxRect);
	CGContextRestoreGState(ctx);
	
	drawGlossAndGradient(ctx, _coloredBoxRect, self.lightColor, self.darkColor);
	
	CGRect outlineRect = rectForStroke(_coloredBoxRect);
	CGContextSetStrokeColorWithColor(ctx, self.darkColor.CGColor);
	CGContextSetLineWidth(ctx, 1);
	CGContextStrokeRect(ctx, outlineRect);	
}


@end
