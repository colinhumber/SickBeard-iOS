//
//  SBSectionHeaderView.m
//  SickBeard
//
//  Created by Colin Humber on 12/13/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBSectionHeaderView.h"

@interface SBSectionHeaderView ()
@property (nonatomic, strong, readwrite) UILabel *sectionLabel;
@end

@implementation SBSectionHeaderView

- (void)commonInit {
	self.state = SBSectionHeaderStateOpen;
	self.backgroundColor = RGBCOLOR(32, 95, 46);
	self.opaque = YES;
	self.sectionLabel = [[UILabel alloc] init];
	self.sectionLabel.opaque = YES;
	self.sectionLabel.backgroundColor = self.backgroundColor;
	self.sectionLabel.font = [UIFont systemFontOfSize:13.0];
	self.sectionLabel.textColor = [UIColor whiteColor];
	[self addSubview:self.sectionLabel];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpen:)];
	[self addGestureRecognizer:tap];
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

- (void)layoutSubviews {
	self.sectionLabel.frame = CGRectInset(self.bounds, 15, 0);
}

- (void)toggleOpen:(UITapGestureRecognizer *)gesture {
	if (self.state == SBSectionHeaderStateClosed) {
		if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)]) {
			[self.delegate sectionHeaderView:self sectionOpened:self.section];
		}
	}
	else {
		if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
			[self.delegate sectionHeaderView:self sectionClosed:self.section];
		}
	}
}


@end
