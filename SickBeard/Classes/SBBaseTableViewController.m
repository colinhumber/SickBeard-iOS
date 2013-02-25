//
//  SBBaseTableViewController.m
//  SickBeard
//
//  Created by Colin Humber on 11/3/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBBaseTableViewController.h"
#import "SVProgressHUD.h"

@implementation SBBaseTableViewController

@synthesize enableRefreshHeader;
@synthesize enableEmptyView;
@synthesize emptyView;
@synthesize tableView;
@synthesize refreshHeader;
@synthesize isDataLoading;
@synthesize loadDate;

- (void)commonInit {
	self.enableRefreshHeader = YES;
	self.enableEmptyView = YES;
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

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
	self.tableView.tableFooterView = [[UIView alloc] init];

	if (self.enableRefreshHeader) {
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
