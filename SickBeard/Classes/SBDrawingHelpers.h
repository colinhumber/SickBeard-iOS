//
//  SBDrawingHelpers.h
//  SickBeard
//
//  Created by Colin Humber on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBDrawingHelpers : NSObject

@end


void drawLinearGradient(CGContextRef ctx, CGRect rect, CGColorRef startColor, CGColorRef endColor);