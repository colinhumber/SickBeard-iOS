//
//  EpisodeCell.m
//  SickBeard
//
//  Created by Colin Humber on 12/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EpisodeCell.h"
#import "SBCellBackground.h"

@implementation EpisodeCell

@synthesize episodeNameLabel;
@synthesize airdateLabel;
@synthesize badgeView;
@synthesize lastCell;

- (void)awakeFromNib {
	self.badgeView.outline = NO;
	self.badgeView.font = [UIFont boldSystemFontOfSize:18];
	self.badgeView.horizontalAlignment = LKBadgeViewHorizontalAlignmentRight;
}

- (void)commonInit {
	SBCellBackground *backgroundView = [[SBCellBackground alloc] init];
	backgroundView.grouped = YES;
	self.backgroundView = backgroundView;
	
	SBCellBackground *selectedBackgroundView = [[SBCellBackground alloc] init];
	selectedBackgroundView.selected = YES;
	selectedBackgroundView.grouped = YES;
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLastCell:(BOOL)last {
	lastCell = last;
	
	SBCellBackground *backgroundView = (SBCellBackground*)self.backgroundView;
	SBCellBackground *selectedBackgroundView = (SBCellBackground*)self.selectedBackgroundView;
	
	backgroundView.lastCell = last;
	selectedBackgroundView.lastCell = last;
	
	backgroundView.applyShadow = last;
	selectedBackgroundView.applyShadow = last;
	
	[backgroundView setNeedsDisplay];
	[selectedBackgroundView setNeedsDisplay];
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}


@end
