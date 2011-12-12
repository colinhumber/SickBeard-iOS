//
//  SBBaseShowCell.h
//  SickBeard
//
//  Created by Colin Humber on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBBaseShowCell : UITableViewCell

- (void)findiTunesArtworkForShow:(NSString*)showName;
- (void)commonInit;

@property (nonatomic, strong) IBOutlet UIImageView *showImageView;
@property (nonatomic, strong) IBOutlet UIImageView *containerView;
@end
