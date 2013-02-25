//
//  SBDrawingHelpers.h
//  SickBeard
//
//  Created by Colin Humber on 12/13/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBDrawingHelpers : NSObject

@end


void drawLinearGradient(CGContextRef ctx, CGRect rect, UIColor *startColor, UIColor *endColor);

CGRect rectForStroke(CGRect rect);

void drawStroke(CGContextRef ctx, CGPoint startPoint, CGPoint endPoint, UIColor *color);

void drawGlossAndGradient(CGContextRef ctx, CGRect rect, UIColor *startColor, UIColor *endColor);