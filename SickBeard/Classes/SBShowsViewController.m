//
//  SBShowsViewController.m
//  SickBeard
//
//  Created by Colin Humber on 8/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBShowsViewController.h"
#import "SickbeardAPIClient.h"
#import "SBShow.h"
#import "PRPAlertView.h"
#import "SBShowDetailsViewController.h"
#import "NSUserDefaults+SickBeard.h"
#import "UIImageView+AFNetworking.h"
#import "ShowCell.h"

@implementation SBShowsViewController

@synthesize tableView;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"ShowDetailsSegue"]) {
		SBShowDetailsViewController *detailsController = [segue destinationViewController];
		detailsController.show = [shows objectAtIndex:[self.tableView indexPathForSelectedRow].row];
	}
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
	refreshHeader.delegate = self;
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
			if (!shows) {
				[shows removeAllObjects];
				[self loadData];
			}
		}		
	}
}

//- (void)viewDidAppear:(BOOL)animated {
//}

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
	[self.hud setCaption:@"Loading shows..."];
	[self.hud show];
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandShows 
									   parameters:nil 
										  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  shows = [[NSMutableArray alloc] init];
												  
												  NSDictionary *dataDict = [JSON objectForKey:@"data"];
												  
												  if (dataDict.allKeys.count > 0) {
													  for (NSString *key in [dataDict allKeys]) {
														  SBShow *show = [SBShow itemWithDictionary:[dataDict objectForKey:key]];
														  show.tvdbID = key;
														  [shows addObject:show];
													  }
												  }
												  else {
													  NSLog(@"No shows");
												  }
											  }
											  else {
												  [PRPAlertView showWithTitle:@"Error retrieving shows" 
																	  message:[JSON objectForKey:@"message"] 
																  buttonTitle:@"OK"];
											  }
										
											  [self finishDataLoad:nil];
											  [self.tableView reloadData];
											  [refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
										  }
										  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
											  [PRPAlertView showWithTitle:@"Error retrieving shows" 
																  message:[NSString stringWithFormat:@"Could not retreive shows \n%@", error.localizedDescription] 
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
- (void)addShow {
	[self performSegueWithIdentifier:@"AddShowSegue" sender:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return shows.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ShowCell *cell = (ShowCell*)[tv dequeueReusableCellWithIdentifier:@"ShowCell"];
	
	SBShow *show = [shows objectAtIndex:indexPath.row];
	cell.showNameLabel.text = show.showName;
	
	[cell.posterImageView setImageWithURL:[[SickbeardAPIClient sharedClient] createUrlWithEndpoint:show.posterUrlPath] 
				   placeholderImage:nil];	
	
	return cell;
}


@end
