//
//  EpisodeCell.h
//  SickBeard
//
//  Created by Colin Humber on 12/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LKBadgeView.h"

@interface EpisodeCell : UITableViewCell

@property (nonatomic, strong) IBOutlet LKBadgeView *badgeView;
@property (nonatomic, strong) IBOutlet UILabel *episodeNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *airdateLabel;
@property (nonatomic) BOOL lastCell;

@end
