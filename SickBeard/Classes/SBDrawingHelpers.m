//
//  SBDrawingHelpers.m
//  SickBeard
//
//  Created by Colin Humber on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBDrawingHelpers.h"

@implementation SBDrawingHelpers

@end

void drawLinearGradient(CGContextRef ctx, CGRect rect, CGColorRef startColor, CGColorRef endColor) {
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGFloat locations[] = { 0.0, 1.0 };
	
	NSArray *colors = [NSArray arrayWithObjects:(__bridge id)startColor, (__bridge id)endColor, nil];
	
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);

	CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
	CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));

	CGContextSaveGState(ctx);
	CGContextAddRect(ctx, rect);
	CGContextClip(ctx);
	CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
	CGContextRestoreGState(ctx);
	
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
}