//
//  ComingEpisodeCell.h
//  SickBeard
//
//  Created by Colin Humber on 9/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComingEpisodeCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *bannerImageView;
@property (nonatomic, strong) IBOutlet UILabel *episodeNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *seasonEpisodeLabel;
@property (nonatomic, strong) IBOutlet UILabel *airDateLabel;

@end
