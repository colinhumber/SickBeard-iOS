//
//  SBShowsViewController.h
//  SickBeard
//
//  Created by Colin Humber on 8/26/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBBaseTableViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "SBAddShowDelegate.h"

@interface SBShowsViewController : SBBaseTableViewController <UITableViewDelegate, UITableViewDataSource, SBAddShowDelegate> 

- (void)addShow;

@end
