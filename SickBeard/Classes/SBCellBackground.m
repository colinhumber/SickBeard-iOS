//
//  SBCellBackground.m
//  SickBeard
//
//  Created by Colin Humber on 12/13/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBCellBackground.h"
#import <QuartzCore/QuartzCore.h>

@implementation SBCellBackground

@synthesize grouped;
@synthesize lastCell;
@synthesize selected;
@synthesize applyShadow;

- (void)commonInit {
	self.grouped = NO;
	self.lastCell = NO;
	self.selected = NO;
	self.applyShadow = YES;
	self.backgroundColor = [UIColor clearColor];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		[self commonInit];
	}
	
	return self;
}

- (id)init {
    self = [super init];
    if (self) {
		[self commonInit];        
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
	if (self.applyShadow) {
		self.layer.shadowColor = [UIColor blackColor].CGColor;
		self.layer.shadowOpacity = 0.7f;
		self.layer.shadowOffset = CGSizeMake(0, 10.0f);
		self.layer.shadowRadius = 5.0f;
		self.layer.masksToBounds = NO;
		
		CGSize size = self.bounds.size;
		CGFloat curlFactor = 15.0f;
		CGFloat shadowDepth = 3.0f;
		UIBezierPath *path = [UIBezierPath bezierPath];
		[path moveToPoint:CGPointMake(0.0f, 0.0f)];
		[path addLineToPoint:CGPointMake(size.width, 0.0f)];
		[path addLineToPoint:CGPointMake(size.width, size.height + shadowDepth)];
		[path addCurveToPoint:CGPointMake(0.0f, size.height + shadowDepth)
				controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor)
				controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor)];
		self.layer.shadowPath = path.CGPath;
	}
	else {
		self.layer.shadowColor = nil;
		self.layer.shadowOpacity = 0;
		self.layer.shadowOffset = CGSizeMake(0, 0);
		self.layer.shadowRadius = 0;
		self.layer.masksToBounds = NO;
		self.layer.shadowPath = nil;
	}
	
    CGContextRef ctx = UIGraphicsGetCurrentContext();

	CGRect paperRect = self.bounds;
	
	// gradient BG
	if (!grouped) {
		paperRect = CGRectInset(self.bounds, 5, 5);
	}
	
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
