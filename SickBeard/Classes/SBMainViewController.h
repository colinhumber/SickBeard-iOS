//
//  SBMainViewController.h
//  SickBeard
//
//  Created by Colin Humber on 11/3/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBBaseViewController;

@interface SBMainViewController : UIViewController

- (IBAction)viewModeChanged:(id)sender;
- (IBAction)refresh:(id)sender;

@property (nonatomic, weak) SBBaseViewController *currentController;

@end
