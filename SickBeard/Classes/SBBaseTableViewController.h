//
//  SBBaseTableViewController.h
//  SickBeard
//
//  Created by Colin Humber on 11/3/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBDataLoader.h"
#import "SBEmptyView.h"
#import "SickbeardAPIClient.h"
#import <TSMessages/TSMessage.h>

@interface SBBaseTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SBDataLoader>

- (void)loadData;
- (void)loadData:(BOOL)showHUD;
- (void)showEmptyView:(BOOL)show animated:(BOOL)animated;

@property (nonatomic) BOOL enableRefreshHeader;
@property (nonatomic) BOOL enableEmptyView;
@property (nonatomic, strong) SBEmptyView *emptyView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) SickbeardAPIClient *apiClient;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end
