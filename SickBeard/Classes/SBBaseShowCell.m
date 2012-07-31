//
//  SBBaseShowCell.m
//  SickBeard
//
//  Created by Colin Humber on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBBaseShowCell.h"
#import "SBCellBackground.h"

@implementation SBBaseShowCell

@synthesize showImageView;
@synthesize containerView;

- (void)awakeFromNib {
	self.showImageView.initialImage = [UIImage imageNamed:@"placeholder"];
}

- (void)commonInit {
	SBCellBackground *backgroundView = [[SBCellBackground alloc] init];
	self.backgroundView = backgroundView;
	
	SBCellBackground *selectedBackgroundView = [[SBCellBackground alloc] init];
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


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)prepareForReuse {
	[self.showImageView prepareForReuse];
	[super prepareForReuse];
}

@end
