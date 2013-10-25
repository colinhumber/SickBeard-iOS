//
//  EpisodeCell.m
//  SickBeard
//
//  Created by Colin Humber on 12/9/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "EpisodeCell.h"

@implementation EpisodeCell

- (void)awakeFromNib {
	self.badgeView.textLabel.font = [UIFont boldSystemFontOfSize:13];
	self.badgeView.badgeAlignment = SAMBadgeViewAlignmentRight;
	
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	self.editingAccessoryType = UITableViewCellAccessoryNone;
}

- (void)commonInit {
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

- (BOOL)canBecomeFirstResponder {
	return YES;
}

@end
