//
//  SBFaqCell.m
//  SickBeard
//
//  Created by Colin Humber on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBFaqCell.h"
#import "SBCellBackground.h"

@implementation SBFaqCell

@synthesize questionLabel;
@synthesize answerLabel;

- (void)commonInit {
	SBCellBackground *backgroundView = [[SBCellBackground alloc] init];
	backgroundView.applyShadow = NO;
	self.backgroundView = backgroundView;
	
	SBCellBackground *selectedBackgroundView = [[SBCellBackground alloc] init];
	selectedBackgroundView.applyShadow = NO;
	selectedBackgroundView.selected = YES;
	self.selectedBackgroundView = selectedBackgroundView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		[self commonInit];		
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		[self commonInit];
	}
	
	return self;
}

@end
