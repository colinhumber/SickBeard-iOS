//
//  SBCellBackground.m
//  SickBeard
//
//  Created by Colin Humber on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBCellBackground.h"
#import <QuartzCore/QuartzCore.h>

@implementation SBCellBackground

@synthesize grouped;
@synthesize lastCell;
@synthesize selected;

- (id)init {
    self = [super init];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();

	// gradient BG
	CGRect paperRect = self.bounds;
	
	UIColor *lightGrayColor = RGBCOLOR(230, 230, 230);
	UIColor *whiteColor = RGBCOLOR(255, 255, 255);
	UIColor *separatorColor = RGBCOLOR(208, 208, 208);
	
	if (selected) {
		drawLinearGradient(ctx, paperRect, lightGrayColor, separatorColor);
	}
	else {
		drawLinearGradient(ctx, paperRect, whiteColor, lightGrayColor);
	}
	
	if (!lastCell) {
		// stroke outline
		CGColorRef strokeColor = [UIColor whiteColor].CGColor;
		
		CGRect strokeRect = paperRect;
		strokeRect.size.height -= 1;
		strokeRect = rectForStroke(strokeRect);
		
		CGContextSetStrokeColorWithColor(ctx, strokeColor);
		CGContextSetLineWidth(ctx, 1);
		CGContextStrokeRect(ctx, strokeRect);
		
		// stroke separator
		CGPoint startPoint = CGPointMake(paperRect.origin.x, paperRect.origin.y + paperRect.size.height - 1);
		CGPoint endPoint = CGPointMake(paperRect.origin.x + paperRect.size.width - 1, paperRect.origin.y + paperRect.size.height - 1);
		drawStroke(ctx, startPoint, endPoint, separatorColor);
	}
	else {
		CGContextSetStrokeColorWithColor(ctx, whiteColor.CGColor);
		CGContextSetLineWidth(ctx, 1);
		
		CGPoint pointA = CGPointMake(paperRect.origin.x, 
									 paperRect.origin.y + paperRect.size.height - 1);
		CGPoint pointB = CGPointMake(paperRect.origin.x, paperRect.origin.y);
		CGPoint pointC = CGPointMake(paperRect.origin.x + paperRect.size.width - 1, 
									 paperRect.origin.y);
		CGPoint pointD = CGPointMake(paperRect.origin.x + paperRect.size.width - 1, 
									 paperRect.origin.y + paperRect.size.height - 1);
		
		drawStroke(ctx, pointA, pointB, whiteColor);
		drawStroke(ctx, pointB, pointC, whiteColor);
		drawStroke(ctx, pointC, pointD, whiteColor);
	}
}


@end
