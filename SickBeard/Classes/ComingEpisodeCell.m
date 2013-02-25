//
//  ComingEpisodeCell.m
//  SickBeard
//
//  Created by Colin Humber on 9/2/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "ComingEpisodeCell.h"
#import "SBCellBackground.h"

@implementation ComingEpisodeCell

@synthesize showNameLabel;
@synthesize networkLabel;
@synthesize episodeNameLabel;
@synthesize airDateLabel;
@synthesize lastCell;

- (void)commonInit {
	[super commonInit];

	SBCellBackground *backgroundView = (SBCellBackground*)self.backgroundView;
	SBCellBackground *selectedBackgroundView = (SBCellBackground*)self.selectedBackgroundView;

	backgroundView.grouped = YES;
	selectedBackgroundView.grouped = YES;

	backgroundView.applyShadow = NO;
	selectedBackgroundView.applyShadow = NO;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
	self.lastCell = NO;
	[super prepareForReuse];
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
