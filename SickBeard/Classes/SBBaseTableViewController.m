//
//  SBBaseTableViewController.m
//  SickBeard
//
//  Created by Colin Humber on 11/3/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBBaseTableViewController.h"
#import "SVProgressHUD.h"
#import "SBServer.h"

@implementation SBBaseTableViewController

@synthesize isDataLoading = _isDataLoading;
@synthesize loadDate = _loadDate;

- (void)commonInit {
	self.enableRefreshHeader = YES;
	self.enableEmptyView = YES;
		
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (defaults.server) {
		self.apiClient = [[SickbeardAPIClient alloc] initWithBaseURL:[NSURL URLWithString:defaults.server.serviceEndpointPath]];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(serverBaseURLDidChange:)
												 name:SBServerURLDidChangeNotification
											   object:nil];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		[self commonInit];
	}
	
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super init];
	
	if (self) {
		[self commonInit];
	}
	
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:SBServerURLDidChangeNotification
												  object:nil];
}


- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
//	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//	self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
	self.tableView.tableFooterView = [[UIView alloc] init];

	if (self.enableRefreshHeader) {
		self.refreshControl = [[UIRefreshControl alloc] init];
		[self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
		[self.tableView addSubview:self.refreshControl];
	}
	
	if (self.enableEmptyView) {
		CGFloat emptyViewHeight = 0;
		if (self.navigationController.toolbar) {
			emptyViewHeight = 372;
		}
		else {
			emptyViewHeight = 416;
			
			if ([UIScreen mainScreen].bounds.size.height == 568) {
				emptyViewHeight += 88;
			}
		}

		self.emptyView = [[SBEmptyView alloc] initWithFrame:CGRectMake(0, 0, 320, emptyViewHeight)];
		[self.view addSubview:self.emptyView];
	}
}

- (void)refresh:(id)sender {
}

- (void)loadData {
	[self loadData:YES];
}

- (void)loadData:(BOOL)showHUD {
	[self showEmptyView:NO animated:NO];
	self.isDataLoading = YES;
}


- (void)finishDataLoad:(NSError*)error {
	self.isDataLoading = NO;
	[SVProgressHUD dismiss];
	
	if (!error) {
		self.loadDate = [NSDate date];
	}
	
	[self.refreshControl endRefreshing];
}

- (void)showEmptyView:(BOOL)show animated:(BOOL)animated {
	CGFloat alpha = show ? 1.0 : 0.0;
	
	if (animated) {
		[UIView animateWithDuration:0.3 
						 animations:^{
							 self.emptyView.alpha = alpha;
						 }];
	}
	else {
		self.emptyView.alpha = alpha;
	}
}

//#pragma mark - UIScrollViewDelegate Methods
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
//	[refreshHeader egoRefreshScrollViewDidScroll:scrollView];
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//	[refreshHeader egoRefreshScrollViewDidEndDragging:scrollView];	
//}
//
//
//#pragma mark - EGORefreshTableHeaderDelegate Methods
//- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {	
//	[self loadData];
//}
//
//- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {	
//	return self.isDataLoading; // should return if data source model is reloading
//}
//
//- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
//	return self.loadDate; // should return date data source was last changed
//}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

#pragma mark - Server Client
- (void)serverBaseURLDidChange:(NSNotification *)notification {
	SBServer *updatedServer = notification.object;
	self.apiClient = [[SickbeardAPIClient alloc] initWithBaseURL:[NSURL URLWithString:updatedServer.serviceEndpointPath]];
}

- (SickbeardAPIClient *)apiClient {
	if (!_apiClient) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		self.apiClient = [[SickbeardAPIClient alloc] initWithBaseURL:[NSURL URLWithString:defaults.server.serviceEndpointPath]];
	}
	
	return _apiClient;
}

@end
