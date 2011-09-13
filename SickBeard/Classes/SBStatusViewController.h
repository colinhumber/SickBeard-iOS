//
//  SBStatusViewController.h
//  SickBeard
//
//  Created by Colin Humber on 9/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SBStatusViewControllerDelegate;

@interface SBStatusViewController : UITableViewController

@property (nonatomic, assign) id<SBStatusViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *currentStatus;

@end


@protocol SBStatusViewControllerDelegate <NSObject>

- (void)statusViewController:(SBStatusViewController*)controller didSelectStatus:(NSString*)status;

@end