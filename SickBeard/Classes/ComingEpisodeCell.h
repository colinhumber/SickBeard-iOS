//
//  ComingEpisodeCell.h
//  SickBeard
//
//  Created by Colin Humber on 9/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBBaseShowCell.h"

@interface ComingEpisodeCell : SBBaseShowCell

@property (nonatomic, strong) IBOutlet UILabel *showNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *networkLabel;
@property (nonatomic, strong) IBOutlet UILabel *episodeNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *airDateLabel;
@property (nonatomic) BOOL lastCell;

@end
