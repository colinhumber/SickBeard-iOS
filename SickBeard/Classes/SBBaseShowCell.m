//
//  SBBaseShowCell.m
//  SickBeard
//
//  Created by Colin Humber on 12/6/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBBaseShowCell.h"

@implementation SBBaseShowCell

- (void)awakeFromNib {
	self.showImageView.image = [UIImage imageNamed:@"placeholder"];
}

- (void)commonInit {
	self.backgroundColor = [UIColor whiteColor];
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
	[super prepareForReuse];
}

@end
