//
//  SBLogCell.m
//  SickBeard
//
//  Created by Colin Humber on 2/26/13.
//
//

#import "SBLogCell.h"
#import "SBCellBackground.h"
#import <QuartzCore/QuartzCore.h>

@implementation SBLogCell

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
