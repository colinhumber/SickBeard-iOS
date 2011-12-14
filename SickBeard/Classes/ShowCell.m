//
//  ShowCell.m
//  SickBeard
//
//  Created by Colin Humber on 9/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ShowCell.h"
#import "SBPlainCellBackground.h"

@implementation ShowCell

@synthesize showNameLabel;
@synthesize networkLabel;
@synthesize statusLabel;
@synthesize nextEpisodeAirdateLabel;

- (void)commonInit {
	self.backgroundView = [[SBPlainCellBackground alloc] init];
	
	SBPlainCellBackground *selectedCellBackground = [[SBPlainCellBackground alloc] init];
	selectedCellBackground.selected = YES;
	self.selectedBackgroundView = selectedCellBackground;
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
