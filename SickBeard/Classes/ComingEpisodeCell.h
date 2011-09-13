//
//  ComingEpisodeCell.h
//  SickBeard
//
//  Created by Colin Humber on 9/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComingEpisodeCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *bannerImageView;
@property (nonatomic, retain) IBOutlet UILabel *episodeNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *seasonEpisodeLabel;
@property (nonatomic, retain) IBOutlet UILabel *airDateLabel;

@end
