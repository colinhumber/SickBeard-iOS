//
//  SBBaseTableViewController.m
//  SickBeard
//
//  Created by Colin Humber on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBBaseTableViewController.h"
#import "SVProgressHUD.h"

@implementation SBBaseTableViewController

@synthesize tableView;
@synthesize refreshHeader;
@synthesize isDataLoading;
@synthesize loadDate;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
	self.tableView.tableFooterView = [[UIView alloc] init];

	self.refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height) 
													  arrowImageName:@"blackArrow" 
														   textColor:[UIColor blackColor] 
													 backgroundColor:[UIColor clearColor] 
													   activityStyle:UIActivityIndicatorViewStyleWhite];
	self.refreshHeader.delegate = self;
	self.refreshHeader.defaultInsets = self.tableView.contentInset;
	[self.tableView addSubview:self.refreshHeader];
	[self.refreshHeader refreshLastUpdatedDate];
}

- (void)refresh:(id)sender {
}

- (void)loadData {	
	self.isDataLoading = YES;
}

- (void)finishDataLoad:(NSError*)error {
	self.isDataLoading = NO;
	
	[SVProgressHUD dismiss];
	
	if (!error) {
		self.loadDate = [NSDate date];
	}
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
	[refreshHeader egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[refreshHeader egoRefreshScrollViewDidEndDragging:scrollView];	
}


#pragma mark - EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {	
	[self loadData];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {	
	return self.isDataLoading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
	return self.loadDate; // should return date data source was last changed
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}


@end
