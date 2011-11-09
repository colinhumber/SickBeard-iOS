//
//  SBHistoryCell.h
//  SickBeard
//
//  Created by Colin Humber on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBHistoryCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *showImageView;
@property (nonatomic, strong) IBOutlet UILabel *showNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *seasonEpisodeLabel;
@property (nonatomic, strong) IBOutlet UILabel *createdDateLabel;
@property (nonatomic, strong) IBOutlet UILabel *qualityLabel;


@end
