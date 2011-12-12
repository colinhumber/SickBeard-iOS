//
//  SBBaseTableViewController.h
//  SickBeard
//
//  Created by Colin Humber on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBDataLoader.h"
#import "EGORefreshTableHeaderView.h"

@interface SBBaseTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate, SBDataLoader>

- (void)loadData;

@property (nonatomic, strong) EGORefreshTableHeaderView *refreshHeader;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
