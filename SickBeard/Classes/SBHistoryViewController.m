//
//  SBHistoryViewController.m
//  SickBeard
//
//  Created by Colin Humber on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBHistoryViewController.h"
#import "SickbeardAPIClient.h"
#import "SBHistory.h"
#import "PRPAlertView.h"
#import "NSUserDefaults+SickBeard.h"
#import "UIImageView+AFNetworking.h"
#import "SBHistoryCell.h"
#import "NSDate+Utilities.h"

@implementation SBHistoryViewController

@synthesize tableView;

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.navigationController.toolbar.frame.size.height, 0);
	self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
	
	refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
	refreshHeader.delegate = self;
	refreshHeader.defaultInsets = self.tableView.contentInset;
	[self.tableView addSubview:refreshHeader];
	[refreshHeader refreshLastUpdatedDate];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if ([self tableView:self.tableView numberOfRowsInSection:0] > 0) {
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
	}
	else {
		if ([NSUserDefaults standardUserDefaults].serverHasBeenSetup) {
			if (!history) {
				[history removeAllObjects];
				[self loadData];
			}
		}		
	}
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Loading
- (void)loadData {
	[super loadData];
	
	[self.hud setActivity:YES];
	[self.hud setCaption:@"Loading history..."];
	[self.hud show];
	
	NSString *filter = @"";
	if (historyType == SBHistoryTypeSnatched) {
		filter = @"snatched";
	}
	else {
		filter = @"downloaded";
	}

	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:filter, @"type", nil];
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandHistory 
									   parameters:params
										  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  history = [[NSMutableArray alloc] init];
												  
												  NSArray *data = [JSON objectForKey:@"data"];
												  
												  if (data.count > 0) {
													  for (NSDictionary *entry in data) {
														  SBHistory *item = [SBHistory itemWithDictionary:entry];
														  [history addObject:item];
													  }
													  
													  NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:NO];
													  [history sortUsingDescriptors:[NSArray arrayWithObject:sorter]];
												  }
												  else {
													  NSLog(@"No history");
												  }
											  }
											  else {
												  [PRPAlertView showWithTitle:@"Error retrieving history" 
																	  message:[JSON objectForKey:@"message"] 
																  buttonTitle:@"OK"];
											  }
											  
											  [self finishDataLoad:nil];
											  [self.tableView reloadData];
											  [refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
										  }
										  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
											  [PRPAlertView showWithTitle:@"Error retrieving history" 
																  message:[NSString stringWithFormat:@"Could not retreive history\n%@", error.localizedDescription] 
															  buttonTitle:@"OK"];			
											  
											  [self finishDataLoad:error];
											  [refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
										  }];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
	[refreshHeader egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[refreshHeader egoRefreshScrollViewDidEndDragging:scrollView];	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {	
	[self loadData];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {	
	return self.isDataLoading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
	return self.loadDate; // should return date data source was last changed
}


#pragma mark - Actions
- (IBAction)done:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)historyTypeChanged:(id)sender {
	historyType = [(UISegmentedControl*)sender selectedSegmentIndex];
	[self loadData];
}

- (IBAction)refresh:(id)sender {
	[self loadData];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return history.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SBHistoryCell *cell = (SBHistoryCell*)[tv dequeueReusableCellWithIdentifier:@"SBHistoryCell"];
	
	SBHistory *entry = [history objectAtIndex:indexPath.row];
	cell.showNameLabel.text = entry.showName;	
	cell.createdDateLabel.text = [entry.createdDate displayDateTimeString];
	cell.seasonEpisodeLabel.text = [NSString stringWithFormat:@"Season %d, Episode %d", entry.season, entry.episode];
	[cell.showImageView setImageWithURL:[[SickbeardAPIClient sharedClient] createUrlWithEndpoint:[SickbeardAPIClient posterUrlPath:entry.tvdbID]]
					   placeholderImage:[UIImage imageNamed:@"Icon"]];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row % 2 == 0) {
		cell.backgroundColor = RGBCOLOR(245, 241, 226); 
	}
	else {
		cell.backgroundColor = RGBCOLOR(223, 218, 206); 		
	}
}


@end
