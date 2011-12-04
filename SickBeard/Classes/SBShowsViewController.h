//
//  SBShowsViewController.h
//  SickBeard
//
//  Created by Colin Humber on 8/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBBaseViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "SBAddShowDelegate.h"

@interface SBShowsViewController : SBBaseViewController <UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate, SBAddShowDelegate> {
	NSMutableArray *shows;
	EGORefreshTableHeaderView *refreshHeader;
}

- (void)addShow;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
