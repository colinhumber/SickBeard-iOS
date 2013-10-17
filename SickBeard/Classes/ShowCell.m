//
//  ShowCell.m
//  SickBeard
//
//  Created by Colin Humber on 9/2/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "ShowCell.h"
#import "SBCellBackground.h"

@implementation ShowCell

- (void)commonInit {
	[super commonInit];
//	SBCellBackground *backgroundView = (SBCellBackground*)self.backgroundView;
//	SBCellBackground *selectedBackgroundView = (SBCellBackground*)self.selectedBackgroundView;
//	
//	backgroundView.applyShadow = NO;
//	selectedBackgroundView.applyShadow = NO;
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


@end
