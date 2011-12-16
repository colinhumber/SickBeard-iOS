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
#import "SBEmptyView.h"

@interface SBBaseTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate, SBDataLoader>

- (void)loadData;
- (void)showEmptyView:(BOOL)show animated:(BOOL)animated;

@property (nonatomic) BOOL enableRefreshHeader;
@property (nonatomic) BOOL enableEmptyView;
@property (nonatomic, strong) SBEmptyView *emptyView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshHeader;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
