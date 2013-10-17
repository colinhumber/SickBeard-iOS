//
//  EpisodeCell.m
//  SickBeard
//
//  Created by Colin Humber on 12/9/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "EpisodeCell.h"
#import "SBCellBackground.h"

@implementation EpisodeCell

- (void)awakeFromNib {
	self.badgeView.textLabel.font = [UIFont boldSystemFontOfSize:13];
	self.badgeView.badgeAlignment = SAMBadgeViewAlignmentRight;
//	self.badgeView.outline = NO;
//	self.badgeView.font = [UIFont boldSystemFontOfSize:13];
//	self.badgeView.horizontalAlignment = LKBadgeViewHorizontalAlignmentRight;
}

- (void)commonInit {
	SBCellBackground *backgroundView = [[SBCellBackground alloc] init];
	backgroundView.grouped = YES;
	self.backgroundView = backgroundView;
	
	SBCellBackground *selectedBackgroundView = [[SBCellBackground alloc] init];
	selectedBackgroundView.selected = YES;
	selectedBackgroundView.grouped = YES;
	self.selectedBackgroundView = selectedBackgroundView;

	self.selectionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"multi-not-checked"]];
	self.selectionImageView.left = 13;
	self.selectionImageView.centerY = round(self.contentView.height / 2);
	self.selectionImageView.alpha = 0.0;
	[self addSubview:self.selectionImageView];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

	if (selected) {
		self.selectionImageView.image = [UIImage imageNamed:@"multi-checked"];
	}
	else {
		self.selectionImageView.image = [UIImage imageNamed:@"multi-not-checked"];
	}
    // Configure the view for the selected state
}

- (void)setLastCell:(BOOL)last {
	_lastCell = last;
	
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [self setNeedsLayout];
}

- (void)layoutSubviews {
	[UIView animateWithDuration:0.3
						  delay:0
						options:UIViewAnimationOptionBeginFromCurrentState
					 animations:^{
						 [super layoutSubviews];
 
						 if (((UITableView *)self.superview).isEditing) {
							 CGRect contentFrame = self.contentView.frame;
							 contentFrame.origin.x = 30;
							 self.contentView.frame = contentFrame;
							 self.chevronImageView.alpha = 0.0f;
							 self.selectionImageView.alpha = 1.0f;
						 }
						 else {
							 CGRect contentFrame = self.contentView.frame;
							 contentFrame.origin.x = 10;
							 self.contentView.frame = contentFrame;
							 self.chevronImageView.alpha = 1.0f;
							 self.selectionImageView.alpha = 0.0f;
						 }
					 }
					 completion:nil];
}


@end
