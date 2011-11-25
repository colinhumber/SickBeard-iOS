//
//  SBMainViewController.h
//  SickBeard
//
//  Created by Colin Humber on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBHudViewController.h"

@class SBShowsViewController;
@class SBEpisodesViewController;

@interface SBMainViewController : UIViewController {
	UIBarButtonItem *addItem;
}

- (IBAction)viewModeChanged:(id)sender;
- (IBAction)refresh:(id)sender;

@property (nonatomic, weak) UIViewController<SBHudViewController> *currentController;

@end
