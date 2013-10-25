//
//  SBBaseShowCell.h
//  SickBeard
//
//  Created by Colin Humber on 12/6/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBBaseShowCell : UITableViewCell

- (void)commonInit;

@property (nonatomic, strong) IBOutlet UIImageView *showImageView;
@property (nonatomic, strong) IBOutlet UIImageView *containerView;

@end
