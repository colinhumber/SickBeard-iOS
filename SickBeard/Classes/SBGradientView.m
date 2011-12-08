//
//  SBGradientView.m
//  SickBeard
//
//  Created by Colin Humber on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBGradientView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SBGradientView

@synthesize colors;

+ (Class)layerClass {
	return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setColors:(NSArray *)c {
	CAGradientLayer *gl = (CAGradientLayer*)self.layer;
	gl.colors = c;
}

- (NSArray*)colors {
	CAGradientLayer *gl = (CAGradientLayer*)self.layer;
	return gl.colors;
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
