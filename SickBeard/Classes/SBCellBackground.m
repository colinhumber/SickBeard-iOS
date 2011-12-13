//
//  SBCellBackground.m
//  SickBeard
//
//  Created by Colin Humber on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBCellBackground.h"

@implementation SBCellBackground

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGRect paperRect = self.bounds;
	drawLinearGradient(ctx, paperRect, RGBCOLOR(255, 255, 255).CGColor, RGBCOLOR(230, 230, 230).CGColor);
}


@end
