//
//  ShowCell.h
//  SickBeard
//
//  Created by Colin Humber on 9/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowCell : UITableViewCell 

- (void)findiTunesArtworkForShow:(NSString*)showName;

@property (nonatomic, strong) IBOutlet UIImageView *posterImageView;
@property (nonatomic, strong) IBOutlet UILabel *showNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *networkLabel;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UILabel *nextEpisodeAirdateLabel;


@end
