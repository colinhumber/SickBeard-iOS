//
//  SBHistoryCell.h
//  SickBeard
//
//  Created by Colin Humber on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBBaseShowCell.h"

@interface SBHistoryCell : SBBaseShowCell

@property (nonatomic, strong) IBOutlet UILabel *showNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *seasonEpisodeLabel;
@property (nonatomic, strong) IBOutlet UILabel *createdDateLabel;
@property (nonatomic, strong) IBOutlet UILabel *qualityLabel;


@end
