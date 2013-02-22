//
//  SBBaseShowCell.h
//  SickBeard
//
//  Created by Colin Humber on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NINetworkImageView.h"

@interface SBBaseShowCell : UITableViewCell

- (void)commonInit;

@property (nonatomic, strong) IBOutlet NINetworkImageView *showImageView;
@property (nonatomic, strong) IBOutlet UIImageView *containerView;

@end
