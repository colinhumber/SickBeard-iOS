//
//  UIView+Layout.m
//  HSW
//
//  Created by Colin Humber on 5/24/12.
//  Copyright (c) 2012 23 Divide Studios. All rights reserved.
//

#import "UIView+Layout.h"

@implementation UIView (Layout)

- (CGFloat)left {
	return self.frame.origin.x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLeft:(CGFloat)x {
	CGRect frame = self.frame;
	frame.origin.x = x;
	self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)top {
	return self.frame.origin.y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTop:(CGFloat)y {
	CGRect frame = self.frame;
	frame.origin.y = y;
	self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)right {
	return self.frame.origin.x + self.frame.size.width;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setRight:(CGFloat)right {
	CGRect frame = self.frame;
	frame.origin.x = right - frame.size.width;
	self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)bottom {
	return self.frame.origin.y + self.frame.size.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBottom:(CGFloat)bottom {
	CGRect frame = self.frame;
	frame.origin.y = bottom - frame.size.height;
	self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)centerX {
	return self.center.x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterX:(CGFloat)centerX {
	self.center = CGPointMake(centerX, self.center.y);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)centerY {
	return self.center.y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterY:(CGFloat)centerY {
	self.center = CGPointMake(self.center.x, centerY);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)width {
	return self.frame.size.width;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setWidth:(CGFloat)width {
	CGRect frame = self.frame;
	frame.size.width = width;
	self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)height {
	return self.frame.size.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHeight:(CGFloat)height {
	CGRect frame = self.frame;
	frame.size.height = height;
	self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)origin {
	return self.frame.origin;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setOrigin:(CGPoint)origin {
	CGRect frame = self.frame;
	frame.origin = origin;
	self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)size {
	return self.frame.size;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSize:(CGSize)size {
	CGRect frame = self.frame;
	frame.size = size;
	self.frame = frame;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeAllSubviews {
	while (self.subviews.count) {
		UIView* child = self.subviews.lastObject;
		[child removeFromSuperview];
	}
}

- (CGSize)layoutSubviews:(NSArray*)subviews flatLayout:(BOOL)flatLayout hPadding:(CGFloat)hPadding vPadding:(CGFloat)vPadding spacing:(CGFloat)spacing {
	CGFloat x = 0, y = 0, maxX = 0, lastHeight = 0, maxWidth = 0, rowHeight = 0;
	
	if (flatLayout) {
		x = hPadding, y = vPadding;
		maxX = 0, lastHeight = 0;
		maxWidth = self.width;
		for (UIView* subview in self.subviews) {
			if (x + subview.width > maxWidth) {
				x = hPadding;
				y += subview.height + spacing;
			}
			subview.left = x;
			subview.top = y;
			x += subview.width + spacing;
			if (x > maxX) {
				maxX = x;
			}
			lastHeight = subview.height;
		}
		
		return CGSizeMake(maxX+hPadding, y+lastHeight+vPadding);
	}
	else {
		x = hPadding, y = vPadding;
		maxX = 0, rowHeight = 0;
		maxWidth = self.frame.size.width - hPadding*2;
		for (UIView* subview in subviews) {
			if (x > hPadding && x + subview.frame.size.width > maxWidth) {
				x = hPadding;
				y += rowHeight + spacing;
				rowHeight = 0;
			}
			subview.frame = CGRectMake(x, y, subview.frame.size.width, subview.frame.size.height);
			x += subview.frame.size.width + spacing;
			if (x > maxX) {
				maxX = x;
			}
			if (subview.frame.size.height > rowHeight) {
				rowHeight = subview.frame.size.height;
			}
		}
		
		return CGSizeMake(maxX+hPadding, y+rowHeight+vPadding);
	}
}


@end
