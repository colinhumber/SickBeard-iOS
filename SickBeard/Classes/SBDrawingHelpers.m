//
//  SBDrawingHelpers.m
//  SickBeard
//
//  Created by Colin Humber on 12/13/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBDrawingHelpers.h"

@implementation SBDrawingHelpers

@end

void drawLinearGradient(CGContextRef context, CGRect rect, UIColor *startColor, UIColor *endColor) {
	// also look at CAGradientLayer
	
	// standard device color space used 99% of the time
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	// 0.0 is the start of the gradient, 1.0 is the end. The first color is at the start (0.0) and the second at the end (1.0)
	CGFloat locations[] = { 0.0, 1.0 };
	
	// colors in the gradient
	NSArray *colors = [NSArray arrayWithObjects:(id)[startColor CGColor], (id)[endColor CGColor], nil];
	
	// create the gradient
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
	
	// determine start/end point of gradient. This is a line from the "top middle" to the "bottom middle" of the rect
	CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
	CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
	
	// save the current state
	CGContextSaveGState(context);
	
	// add the specified rect to the context
	CGContextAddRect(context, rect);
	
	// restrict drawing to an arbitrary shape (in this case the passed in rect)
	CGContextClip(context);
	
	// draw the gradient
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	
	// restore the current state (eg. remove the clipping)
	CGContextRestoreGState(context);
	
	// release
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
}	

CGRect rectForStroke(CGRect rect) {
	return CGRectMake(rect.origin.x + 0.5, rect.origin.y + 0.5, rect.size.width - 1, rect.size.height - 1);
}

void drawStroke(CGContextRef ctx, CGPoint startPoint, CGPoint endPoint, UIColor *color) {
	CGContextSaveGState(ctx);
	
	CGContextSetLineCap(ctx, kCGLineCapSquare);
	CGContextSetStrokeColorWithColor(ctx, [color CGColor]);
	CGContextSetLineWidth(ctx, 1);
	CGContextMoveToPoint(ctx, startPoint.x + 0.5, startPoint.y + 0.5);
	CGContextAddLineToPoint(ctx, endPoint.x + 0.5, endPoint.y + 0.5);
	CGContextStrokePath(ctx);
	
	CGContextRestoreGState(ctx);
}

void drawGlossAndGradient(CGContextRef ctx, CGRect rect, UIColor *startColor, UIColor *endColor) {
	drawLinearGradient(ctx, rect, startColor, endColor);
	
	UIColor *glossColor1 = RGBACOLOR(255, 255, 255, 0.35);
	UIColor *glossColor2 = RGBACOLOR(255, 255, 255, 0.1);
	
	CGRect topHalf = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height/2);
	
	drawLinearGradient(ctx, topHalf, glossColor1, glossColor2);
}