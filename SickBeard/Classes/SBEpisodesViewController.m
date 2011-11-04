//
//  SBEpisodesViewController.m
//  SickBeard
//
//  Created by Colin Humber on 8/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBEpisodesViewController.h"
#import "SickbeardAPIClient.h"
#import "NSUserDefaults+SickBeard.h"
#import "OrderedDictionary.h"
#import "SBComingEpisode.h"
#import "PRPAlertView.h"
#import "NSDate+Utilities.h"
#import "ComingEpisodeCell.h"
#import "UIImageView+AFNetworking.h"

@implementation SBEpisodesViewController

@synthesize tableView;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use. 
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

- (void)viewDidAppear:(BOOL)animated {
	if ([NSUserDefaults standardUserDefaults].serverHasBeenSetup) {
		[comingEpisodes removeAllObjects];
		
		if (!comingEpisodes) {
			[self loadData];
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
	[self.hud setCaption:@"Loading shows..."];
	[self.hud show];
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandComingEpisodes 
									   parameters:nil 
										  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  comingEpisodes = [[OrderedDictionary alloc] init];
												  
												  NSMutableArray *episodes = [NSMutableArray array];
												  NSDictionary *dataDict = [JSON objectForKey:@"data"];
												  
												  for (NSString *key in [dataDict allKeys]) {
													  for (NSDictionary *epDict in [dataDict objectForKey:key]) {
														  SBComingEpisode *ep = [SBComingEpisode itemWithDictionary:epDict];
														  [episodes addObject:ep];
													  }
												  }
												  
												  NSMutableArray *past = [NSMutableArray array];
												  NSMutableArray *today = [NSMutableArray array];
												  NSMutableArray *thisWeek = [NSMutableArray array];
												  NSMutableArray *nextWeek = [NSMutableArray array];
												  NSMutableArray *future = [NSMutableArray array];
												  
												  for (SBComingEpisode *episode in episodes) {
													  if ([episode.airDate isEarlierThanDate:[NSDate date]]) {
														  [past addObject:episode];
													  }
													  else if ([episode.airDate isToday]) {
														  [today addObject:episode];
													  }
													  else if ([episode.airDate isThisWeek]) {
														  [thisWeek addObject:episode];
													  }
													  else if ([episode.airDate isNextWeek]) {
														  [nextWeek addObject:episode];
													  }
													  else {
														  [future addObject:episode];
													  }
												  }
												  
												  if (past.count) [comingEpisodes setObject:past forKey:@"Past"];
												  if (today.count) [comingEpisodes setObject:today forKey:@"Today"];
												  if (thisWeek.count) [comingEpisodes setObject:thisWeek forKey:@"This Week"];
												  if (nextWeek.count) [comingEpisodes setObject:nextWeek forKey:@"Next Week"];
												  if (future.count) [comingEpisodes setObject:future forKey:@"Future"];												  
												  
												  [self.tableView reloadData];
												  
												  [self finishDataLoad:nil];
												  [refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];

											  }
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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return [[comingEpisodes allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [[comingEpisodes allKeys] objectAtIndex:section];
}
	
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *keys = [comingEpisodes allKeys];
	NSString *sectionKey = [keys objectAtIndex:section];
	
	return [[comingEpisodes objectForKey:sectionKey] count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ComingEpisodeCell *cell = (ComingEpisodeCell*)[tv dequeueReusableCellWithIdentifier:@"ComingEpisodeCell"];
	
	NSArray *keys = [comingEpisodes allKeys];
	NSString *sectionKey = [keys objectAtIndex:indexPath.section];
	SBComingEpisode *episode = [[comingEpisodes objectForKey:sectionKey] objectAtIndex:indexPath.row];
	
	[cell.bannerImageView setImageWithURL:[[SickbeardAPIClient sharedClient] createUrlWithEndpoint:episode.bannerUrlPath] 
						 placeholderImage:nil];	

	cell.episodeNameLabel.text = episode.name;
	cell.seasonEpisodeLabel.text = [NSString stringWithFormat:@"Season %d, Episode %d", episode.season, episode.number];
	cell.airDateLabel.text = [NSString stringWithFormat:@"%@ on %@ (%@)", [episode.airDate displayString], episode.network, episode.quality];
	
	return cell;
}

@end
