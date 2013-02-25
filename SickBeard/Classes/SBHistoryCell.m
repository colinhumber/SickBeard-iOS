//
//  SBHistoryCell.m
//  SickBeard
//
//  Created by Colin Humber on 11/8/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBHistoryCell.h"
#import "SBCellBackground.h"

@implementation SBHistoryCell

@synthesize showImageView;
@synthesize showNameLabel;
@synthesize seasonEpisodeLabel;
@synthesize createdDateLabel;
@synthesize qualityLabel;

- (void)awakeFromNib {
	self.showImageView.initialImage = [UIImage imageNamed:@"placeholder"];
}

- (void)commonInit {
	[super commonInit];
	SBCellBackground *backgroundView = (SBCellBackground*)self.backgroundView;
	SBCellBackground *selectedBackgroundView = (SBCellBackground*)self.selectedBackgroundView;
	
	backgroundView.applyShadow = NO;
	selectedBackgroundView.applyShadow = NO;
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
