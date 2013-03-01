//
//  SBShowDetailsViewController.m
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBShowDetailsViewController.h"
#import "SickbeardAPIClient.h"
#import "SBShow.h"
#import "PRPAlertView.h"
#import "SBEpisode.h"
#import "OrderedDictionary.h"
#import "NSDate+Utilities.h"
#import "SVModalWebViewController.h"
#import "EpisodeCell.h"
#import "SBShowDetailsHeaderView.h"
#import "SBSectionHeaderView.h"

#import "AFHTTPClient.h"
#import "SBServer.h"
#import "SBCommandBuilder.h"

@interface SBShowDetailsViewController () <SBSectionHeaderViewDelegate> {
	OrderedDictionary *_seasons;
	NSMutableArray *_sectionHeaders;
	
	struct {
		int menuIsShowing:1;
		int menuIsHiding:1;
	} _menuFlags;
	NSIndexPath *_menuIndexPath;
}

- (void)changeEpisodeStatus:(EpisodeStatus)status;

@end

@implementation SBShowDetailsViewController

@synthesize show;
@synthesize detailsHeaderView;
@synthesize currentEpisodeIndexPath;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"EpisodeDetailsSegue"]) {
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		SBEpisodeDetailsViewController *vc = segue.destinationViewController;
		vc.dataSource = self;
		
		NSArray *seasonKeys = [_seasons allKeys];
		SBEpisode *episode = [[_seasons objectForKey:[seasonKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
		vc.episode = episode;
		self.currentEpisodeIndexPath = indexPath;
	}
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
	self.enableEmptyView = NO;
	
    [super viewDidLoad];
	
	_menuFlags.menuIsShowing = NO;
	_menuFlags.menuIsHiding = NO;
	
	[TestFlight passCheckpoint:@"Viewed show details"];
	
	_seasons = [[OrderedDictionary alloc] init];
	_sectionHeaders = [[NSMutableArray alloc] init];
	self.title = show.showName;
	
	UINib *headerNib = [UINib nibWithNibName:@"SBShowDetailsHeaderView" bundle:nil];
	[headerNib instantiateWithOwner:self options:nil];
	self.detailsHeaderView.showNameLabel.text = show.showName;
	
	[self.detailsHeaderView.showImageView setPathToNetworkImage:[[[SickbeardAPIClient sharedClient] posterURLForTVDBID:show.tvdbID] absoluteString]];
	self.detailsHeaderView.networkLabel.text = show.network;
	
	self.detailsHeaderView.statusLabel.text = [SBShow showStatusAsString:show.status];
	if (show.status == ShowStatusContinuing) {
		self.detailsHeaderView.statusLabel.textColor = RGBCOLOR(21, 93, 45);
	}
	else if (show.status == ShowStatusEnded) {
		self.detailsHeaderView.statusLabel.textColor = RGBCOLOR(202, 50, 56);
	}
	else {
		self.detailsHeaderView.statusLabel.textColor = [UIColor grayColor];
	}
	
	self.tableView.tableHeaderView = self.detailsHeaderView;
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	[self setupNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
	[self loadData];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self setupToolbarItems];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

#pragma mark - Setup
- (void)setupNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(menuControllerWillHide:)
												 name:UIMenuControllerWillHideMenuNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(menuControllerDidHide:)
												 name:UIMenuControllerDidHideMenuNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(menuControllerWillShow:)
												 name:UIMenuControllerWillShowMenuNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(menuControllerDidShow:)
												 name:UIMenuControllerDidShowMenuNotification
											   object:nil];

}

- (void)setupToolbarItems {
	UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[searchButton setBackgroundImage:[[UIImage imageNamed:@"toolbar-button-mask"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)] forState:UIControlStateNormal];
	[searchButton setTitle:@"Search" forState:UIControlStateNormal];
	searchButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
	searchButton.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
	[searchButton sizeToFit];
	searchButton.width = 100;
	[searchButton addTarget:self action:@selector(searchForMultipleEpisodes:) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *setStatusButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[setStatusButton setBackgroundImage:[[UIImage imageNamed:@"toolbar-button-mask"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)] forState:UIControlStateNormal];
	[setStatusButton setTitle:@"Set Status" forState:UIControlStateNormal];
	setStatusButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
	setStatusButton.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
	[setStatusButton sizeToFit];
	setStatusButton.width = 100;
	[setStatusButton addTarget:self action:@selector(setStatusForMultipleEpisodes:) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *searchBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
	UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *setStatusBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:setStatusButton];
	
	self.toolbarItems = @[ searchBarButtonItem, flexibleItem, setStatusBarButtonItem ];
}

#pragma mark - Notification Handlers
- (void)menuControllerWillHide:(NSNotification *)notification {
	_menuFlags.menuIsHiding = YES;
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)menuControllerDidHide:(NSNotification*)notification {
	_menuFlags.menuIsShowing = NO;
	_menuFlags.menuIsHiding = NO;
}

- (void)menuControllerWillShow:(NSNotification *)notification {
	self.tableView.scrollEnabled = NO;
}

- (void)menuControllerDidShow:(NSNotification *)notification {
	_menuFlags.menuIsShowing = YES;
	self.tableView.scrollEnabled = YES;
}

#pragma mark - Loading
- (void)loadData:(BOOL)showHUD {
	if (showHUD) {
		[SVProgressHUD showWithStatus:NSLocalizedString(@"Loading show details", @"Loading show details")];
	}
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandSeasons
									   parameters:[NSDictionary dictionaryWithObject:show.tvdbID forKey:@"tvdbid"]
										  success:^(NSURLRequest *request, NSURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  NSDictionary *dataDict = [JSON objectForKey:@"data"];
												  
												  NSArray *seasonNumbers = [[dataDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *s1, NSString *s2) {
													  if ([s1 intValue] < [s2 intValue]) {
														  return NSOrderedDescending;
													  }
													  else if ([s1 intValue] > [s2 intValue]) {
														  return NSOrderedAscending;
													  }
													  else {
														  return NSOrderedSame;
													  }
												  }];
												  
												  int totalEpisodes = 0;
												  int totalDownloadedEpisodes = 0;
												  
												  for (NSString *seasonNumber in seasonNumbers) {
													  NSMutableArray *episodes = [NSMutableArray array];
													  
													  NSDictionary *seasonDict = [dataDict objectForKey:seasonNumber];
													  
													  for (NSString *episodeNumber in [seasonDict allKeys]) {
														  SBEpisode *episode = [SBEpisode itemWithDictionary:[seasonDict objectForKey:episodeNumber]];
														  
														  episode.show = show;
														  episode.season = [seasonNumber intValue];
														  episode.number = [episodeNumber intValue];
														  [episodes addObject:episode];
														  
														  totalEpisodes++;
														  if (episode.status == EpisodeStatusDownloaded) {
															  totalDownloadedEpisodes++;
														  }
													  }
													  
													  [episodes sortUsingComparator:^NSComparisonResult(SBEpisode *ep1, SBEpisode *ep2) {
														  if (ep1.number > ep2.number) {
															  return NSOrderedAscending;
														  }
														  else if (ep1.number < ep2.number) {
															  return NSOrderedDescending;
														  }
														  else {
															  return NSOrderedSame;
														  }
													  }];
													  
													  [_seasons setObject:episodes forKey:seasonNumber];
													  [_sectionHeaders addObject:[NSNull null]];
												  }

												  self.detailsHeaderView.episodeCountLabel.text = [NSString stringWithFormat:@"%d/%d", totalDownloadedEpisodes, totalEpisodes];
												  
												  float progress = 0;
												  if (totalEpisodes > 0) {
													  progress = (float)totalDownloadedEpisodes/totalEpisodes;
												  }
												  [self.detailsHeaderView.progressBar setProgress:progress];

												  [self finishDataLoad:nil];
												  [self.tableView reloadData];
												  [self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
											  }
											  else {
												  [self finishDataLoad:nil];
												  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving shows", @"Error retrieving shows") 
																	  message:[JSON objectForKey:@"message"] 
																  buttonTitle:NSLocalizedString(@"OK", @"OK")];
												  [self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
											  }
										  }
										  failure:^(NSURLRequest *request, NSURLResponse *response, NSError *error, id JSON) {
											  [self finishDataLoad:error];
											  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving show information", @"Error retrieving show information") 
																  message:error.localizedDescription 
															  buttonTitle:NSLocalizedString(@"OK", @"OK")];		
											  [self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
										  }];
}

#pragma mark - Batch Actions
- (void)searchForMultipleEpisodes:(UIButton *)sender {
	SBServer *currentServer = [NSUserDefaults standardUserDefaults].server;
	AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:currentServer.serviceEndpointPath]];
	NSMutableArray *requests = [NSMutableArray arrayWithCapacity:self.tableView.indexPathsForSelectedRows.count];
	
	for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
		NSArray *keys = [_seasons allKeys];
		NSString *sectionKey = [keys objectAtIndex:indexPath.section];
		NSArray *episodes = [_seasons objectForKey:sectionKey];
		
		SBEpisode *episode = [episodes objectAtIndex:indexPath.row];

		NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
								show.tvdbID, @"tvdbid",
								[NSNumber numberWithInt:episode.season], @"season",
								[NSNumber numberWithInt:episode.number], @"episode", nil];
		
		NSString *urlPath = [SBCommandBuilder URLForCommand:SickBeardCommandEpisodeSearch
											  server:currentServer
											  params:params];

		[requests addObject:[NSURLRequest requestWithURL:[NSURL URLWithString:urlPath]]];
	}
	
	[self setEditing:NO animated:YES];

	[[SBNotificationManager sharedManager] queueNotificationWithText:[NSString stringWithFormat:@"Searching for %d episodes", requests.count]
																type:SBNotificationTypeInfo];
	
	[client enqueueBatchOfHTTPRequestOperationsWithRequests:requests
											  progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
												  
											  }
											completionBlock:^(NSArray *operations) {
												[[SBNotificationManager sharedManager] queueNotificationWithText:@"Finished searching for episodes."
																											type:SBNotificationTypeInfo];
											}];
}

- (void)setStatusForMultipleEpisodes:(UIButton *)sender {
	UIMenuController *menu = [UIMenuController sharedMenuController];
	UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:[SBEpisode episodeStatusAsString:EpisodeStatusWanted] action:@selector(setEpisodeStatusToWantedBatch)];
	UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:[SBEpisode episodeStatusAsString:EpisodeStatusSkipped] action:@selector(setEpisodeStatusToSkippedBatch)];
	UIMenuItem *item3 = [[UIMenuItem alloc] initWithTitle:[SBEpisode episodeStatusAsString:EpisodeStatusArchived] action:@selector(setEpisodeStatusToArchivedBatch)];
	UIMenuItem *item4 = [[UIMenuItem alloc] initWithTitle:[SBEpisode episodeStatusAsString:EpisodeStatusIgnored] action:@selector(setEpisodeStatusToIgnoredBatch)];
	
	menu.menuItems = [NSArray arrayWithObjects:item1, item2, item3, item4, nil];

    CGRect buttonFrame = [sender convertRect:sender.frame toView:self.view];
	
	[menu setTargetRect:buttonFrame inView:self.view];
	[menu setMenuVisible:YES animated:YES];
}

- (void)setEpisodeStatusToWantedBatch {
	[self changeEpisodeStatusBatch:EpisodeStatusWanted];
}

- (void)setEpisodeStatusToSkippedBatch {
	[self changeEpisodeStatusBatch:EpisodeStatusSkipped];
}

- (void)setEpisodeStatusToArchivedBatch {
	[self changeEpisodeStatusBatch:EpisodeStatusArchived];
}

- (void)setEpisodeStatusToIgnoredBatch {
	[self changeEpisodeStatusBatch:EpisodeStatusIgnored];
}

- (void)changeEpisodeStatusBatch:(EpisodeStatus)status {
	SBServer *currentServer = [NSUserDefaults standardUserDefaults].server;
	AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:currentServer.serviceEndpointPath]];
	NSMutableArray *requests = [NSMutableArray arrayWithCapacity:self.tableView.indexPathsForSelectedRows.count];
	NSString *statusString = [[SBEpisode episodeStatusAsString:status] lowercaseString];

	for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
		NSArray *keys = [_seasons allKeys];
		NSString *sectionKey = [keys objectAtIndex:indexPath.section];
		NSArray *episodes = [_seasons objectForKey:sectionKey];
		SBEpisode *episode = [episodes objectAtIndex:indexPath.row];
				
		NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
								episode.show.tvdbID, @"tvdbid",
								[NSNumber numberWithInt:episode.season], @"season",
								[NSNumber numberWithInt:episode.number], @"episode",
								statusString, @"status", nil];
		
		NSString *urlPath = [SBCommandBuilder URLForCommand:SickBeardCommandEpisodeSetStatus
													 server:currentServer
													 params:params];
		
		[requests addObject:[NSURLRequest requestWithURL:[NSURL URLWithString:urlPath]]];
	}
	
	[[SBNotificationManager sharedManager] queueNotificationWithText:[NSString stringWithFormat:@"Setting %d episodes to %@", requests.count, statusString]
																type:SBNotificationTypeInfo];

	[self setEditing:NO animated:YES];

	[client enqueueBatchOfHTTPRequestOperationsWithRequests:requests
											  progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
												  
											  }
											completionBlock:^(NSArray *operations) {
												[self loadData];
												[[SBNotificationManager sharedManager] queueNotificationWithText:[NSString stringWithFormat:@"Episode statuses set to %@.", statusString]
																											type:SBNotificationTypeInfo];
											}];
}

#pragma mark - SBEpisodeDetailsDataSource
- (SBEpisode*)nextEpisode {
	SBEpisode *episode = nil;

	NSArray *seasonKeys = [_seasons allKeys];

	if (self.currentEpisodeIndexPath.section == seasonKeys.count) {
		return nil;
	}

	NSArray *seasonEpisodes = [_seasons objectForKey:[seasonKeys objectAtIndex:self.currentEpisodeIndexPath.section]];
	
	NSIndexPath *nextEpisodeIndexPath = [NSIndexPath indexPathForRow:self.currentEpisodeIndexPath.row - 1 inSection:self.currentEpisodeIndexPath.section];
	
	if (nextEpisodeIndexPath.row >= 0) {	// check if the next episode lies within the current season
		episode = [seasonEpisodes objectAtIndex:nextEpisodeIndexPath.row];
	}
	else {	// move the previous season		
		if (nextEpisodeIndexPath.section - 1 >= 0) {	// check if the next season lies within the bounds of the number of seasons
			seasonEpisodes = [_seasons objectForKey:[seasonKeys objectAtIndex:self.currentEpisodeIndexPath.section - 1]];
			nextEpisodeIndexPath = [NSIndexPath indexPathForRow:seasonEpisodes.count - 1 inSection:self.currentEpisodeIndexPath.section - 1];
			episode = [seasonEpisodes objectAtIndex:nextEpisodeIndexPath.row];
		}
	}
	
	if (episode) {
		self.currentEpisodeIndexPath = nextEpisodeIndexPath;
	}
	
	return episode;
}

- (SBEpisode*)previousEpisode {
	SBEpisode *episode = nil;
	
	NSArray *seasonKeys = [_seasons allKeys];
	
	if (self.currentEpisodeIndexPath.section == seasonKeys.count) {
		return nil;
	}
	
	NSArray *seasonEpisodes = [_seasons objectForKey:[seasonKeys objectAtIndex:self.currentEpisodeIndexPath.section]];
	
	NSIndexPath *previousEpisodeIndexPath = [NSIndexPath indexPathForRow:self.currentEpisodeIndexPath.row + 1 inSection:self.currentEpisodeIndexPath.section];

	if (previousEpisodeIndexPath.row < seasonEpisodes.count) {	// check if the previous episode lies within the current season
		episode = [seasonEpisodes objectAtIndex:previousEpisodeIndexPath.row];
	}
	else {	// move the next season
		previousEpisodeIndexPath = [NSIndexPath indexPathForRow:0 inSection:self.currentEpisodeIndexPath.section + 1];
		
		if (previousEpisodeIndexPath.section < seasonKeys.count) {	// check if the previous season lies within the bounds of the number of seasons
			seasonEpisodes = [_seasons objectForKey:[seasonKeys objectAtIndex:previousEpisodeIndexPath.section]];
			episode = [seasonEpisodes objectAtIndex:previousEpisodeIndexPath.row];
		}
	}
	
	if (episode) {
		self.currentEpisodeIndexPath = previousEpisodeIndexPath;
	}
	
	return episode;
}

#pragma mark - Editing
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:animated];
	
	[self.navigationController setToolbarHidden:!editing animated:animated];
	
//	if (editing) {
//		self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.navigationController.toolbar.frame.size.height, 0);
//	}
//	else {
//		self.tableView.contentInset = UIEdgeInsetsZero;
//	}
//	
//	self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return [[_seasons allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *title = @"";
	
	NSArray *keys = [_seasons allKeys];
	NSString *sectionKey = [keys objectAtIndex:section];
	
	if ([sectionKey isEqualToString:@"0"]) {
		title = NSLocalizedString(@"Specials", @"Specials");
	}
	else {
		title = [NSString stringWithFormat:NSLocalizedString(@"Season %@", @"Season %@"), sectionKey];
	}
	
	return title;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString *title = [self tableView:tableView titleForHeaderInSection:section];

	id header = [_sectionHeaders objectAtIndex:section];
	
	if (header == [NSNull null]) {
		SBSectionHeaderView *sectionHeader = [[SBSectionHeaderView alloc] init];
		sectionHeader.section = section;
		sectionHeader.delegate = self;
		sectionHeader.sectionLabel.text = title;

		[_sectionHeaders replaceObjectAtIndex:section withObject:sectionHeader];
		header = sectionHeader;
	}
	return header;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 50;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *keys = [_seasons allKeys];
	NSString *sectionKey = [keys objectAtIndex:section];
	
	SBSectionHeaderView *headerView = (SBSectionHeaderView *)[self tableView:tableView viewForHeaderInSection:section];
	
	return headerView.state == SBSectionHeaderStateOpen ? [[_seasons objectForKey:sectionKey] count] : 0;
}


- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	EpisodeCell *cell = (EpisodeCell*)[tv dequeueReusableCellWithIdentifier:@"EpisodeCell"];
	
	NSArray *keys = [_seasons allKeys];
	NSString *sectionKey = [keys objectAtIndex:indexPath.section];
	NSArray *episodes = [_seasons objectForKey:sectionKey];
	
	SBEpisode *episode = [episodes objectAtIndex:indexPath.row];
	
	cell.episodeNameLabel.text = episode.name;
	cell.airdateLabel.text = episode.airDate ? [episode.airDate displayString] : NSLocalizedString(@"Unknown Air Date", @"Unknown Air Date");
	cell.badgeView.text = [SBEpisode episodeStatusAsString:episode.status];
	
	UIColor *badgeColor = nil;
	
	switch (episode.status) {
		case EpisodeStatusWanted:
			badgeColor = RGBCOLOR(231, 147, 0);
			break;
			
		case EpisodeStatusDownloaded:
			badgeColor = RGBCOLOR(21, 93, 45);
			break;
			
		case EpisodeStatusSnatched:
			badgeColor = RGBCOLOR(138, 88, 0);
			break;
			
		case EpisodeStatusSkipped:
			badgeColor = RGBCOLOR(202, 50, 56);
			break;
			
		case EpisodeStatusUnaired:
			badgeColor = [UIColor darkGrayColor];
			break;
			
		default:
			badgeColor = [UIColor blackColor];
			break;
	}
	cell.badgeView.badgeColor = badgeColor;
	
	if (indexPath.row == episodes.count - 1) {
		cell.lastCell = YES;
	}
	else {
		cell.lastCell = NO;
	}	
	
	UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
	[cell addGestureRecognizer:gesture];
	
	return cell;
}

#pragma mark - UITableViewDelegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_menuFlags.menuIsShowing || _menuFlags.menuIsHiding) {
		return nil;
	}
	
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_menuFlags.menuIsShowing || _menuFlags.menuIsHiding) {
		return;
	}
	
	if (!self.tableView.editing) {
		[self performSegueWithIdentifier:@"EpisodeDetailsSegue" sender:nil];
	}
}

#pragma mark - Menu Actions
- (void)showMenu:(UIGestureRecognizer*)gesture {
	if (gesture.state == UIGestureRecognizerStateBegan) {
		[gesture.view becomeFirstResponder];
		
		_menuIndexPath = [self.tableView indexPathForRowAtPoint:[gesture locationInView:self.tableView]];
		
		NSArray *keys = [_seasons allKeys];
		NSString *sectionKey = [keys objectAtIndex:_menuIndexPath.section];
		NSArray *episodes = [_seasons objectForKey:sectionKey];
		SBEpisode *episode = [episodes objectAtIndex:_menuIndexPath.row];
		
		NSMutableArray *menuItems = [NSMutableArray array];
		
		[menuItems addObject:[[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Search", @"Search") action:@selector(searchForEpisode)]];
		
		if (episode.status != EpisodeStatusUnaired && episode.status != EpisodeStatusDownloaded) {
			[menuItems addObject:[[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Set Status", @"Set Status") action:@selector(setEpisodeStatus)]];
		}
		
		UIMenuController *menu = [UIMenuController sharedMenuController];
		menu.menuItems = menuItems;
		[menu setTargetRect:gesture.view.frame inView:gesture.view.superview];
		[menu setMenuVisible:YES animated:YES];
	
		[self.tableView selectRowAtIndexPath:_menuIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
}

- (void)searchForEpisode {
	NSArray *keys = [_seasons allKeys];
	NSString *sectionKey = [keys objectAtIndex:_menuIndexPath.section];
	NSArray *episodes = [_seasons objectForKey:sectionKey];
	SBEpisode *episode = [episodes objectAtIndex:_menuIndexPath.row];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							show.tvdbID, @"tvdbid", 
							[NSNumber numberWithInt:episode.season], @"season",
							[NSNumber numberWithInt:episode.number], @"episode", nil];
	
	[[SBNotificationManager sharedManager] queueNotificationWithText:NSLocalizedString(@"Searching for episode", @"Searching for episode")
																type:SBNotificationTypeInfo];
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandEpisodeSearch 
									   parameters:params 
										  success:^(NSURLRequest *request, NSURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  [[SBNotificationManager sharedManager] queueNotificationWithText:NSLocalizedString(@"Episode found and is downloading", @"Episode found and is downloading")
																											  type:SBNotificationTypeSuccess];
												  [self loadData:NO];
											  }
											  else {
												  [[SBNotificationManager sharedManager] queueNotificationWithText:JSON[@"mesage"]
																											  type:SBNotificationTypeError];
											  }
										  }
										  failure:^(NSURLRequest *request, NSURLResponse *response, NSError *error, id JSON) {
											  [PRPAlertView showWithTitle:NSLocalizedString(@"Error searching for show", @"Error searching for show") 
																  message:error.localizedDescription 
															  buttonTitle:NSLocalizedString(@"OK", @"OK")];	
										  }];
}

- (void)setEpisodeStatus {
	UIMenuController *menu = [UIMenuController sharedMenuController];
	UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:[SBEpisode episodeStatusAsString:EpisodeStatusWanted] action:@selector(setEpisodeStatusToWanted)];
	UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:[SBEpisode episodeStatusAsString:EpisodeStatusSkipped] action:@selector(setEpisodeStatusToSkipped)];
	UIMenuItem *item3 = [[UIMenuItem alloc] initWithTitle:[SBEpisode episodeStatusAsString:EpisodeStatusArchived] action:@selector(setEpisodeStatusToArchived)];
	UIMenuItem *item4 = [[UIMenuItem alloc] initWithTitle:[SBEpisode episodeStatusAsString:EpisodeStatusIgnored] action:@selector(setEpisodeStatusToIgnored)];
	
	menu.menuItems = [NSArray arrayWithObjects:item1, item2, item3, item4, nil];

	RunAfterDelay(0.3, ^{
		[menu setMenuVisible:YES animated:YES];
	});
}

- (void)setEpisodeStatusToWanted {
	[self changeEpisodeStatus:EpisodeStatusWanted];
}

- (void)setEpisodeStatusToSkipped {
	[self changeEpisodeStatus:EpisodeStatusSkipped];
}

- (void)setEpisodeStatusToArchived {
	[self changeEpisodeStatus:EpisodeStatusArchived];
}

- (void)setEpisodeStatusToIgnored {
	[self changeEpisodeStatus:EpisodeStatusIgnored];
}

- (void)changeEpisodeStatus:(EpisodeStatus)status {
	NSArray *keys = [_seasons allKeys];
	NSString *sectionKey = [keys objectAtIndex:_menuIndexPath.section];
	NSArray *episodes = [_seasons objectForKey:sectionKey];
	SBEpisode *episode = [episodes objectAtIndex:_menuIndexPath.row];

	NSString *statusString = [[SBEpisode episodeStatusAsString:status] lowercaseString];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							episode.show.tvdbID, @"tvdbid", 
							[NSNumber numberWithInt:episode.season], @"season",
							[NSNumber numberWithInt:episode.number], @"episode",
							statusString, @"status", nil];
	
	[[SBNotificationManager sharedManager] queueNotificationWithText:[NSString stringWithFormat:NSLocalizedString(@"Setting episode status to %@", @"Setting episode status to %@"), statusString]
																type:SBNotificationTypeInfo];
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandEpisodeSetStatus 
									   parameters:params 
										  success:^(NSURLRequest *request, NSURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  [[SBNotificationManager sharedManager] queueNotificationWithText:NSLocalizedString(@"Status successfully set!", @"Status successfully set!")
																											  type:SBNotificationTypeSuccess];
												  [self loadData:NO];
											  }
											  else {
												  [[SBNotificationManager sharedManager] queueNotificationWithText:JSON[@"message"]
																											  type:SBNotificationTypeError];
											  }
										  }
										  failure:^(NSURLRequest *request, NSURLResponse *response, NSError *error, id JSON) {
											  [PRPAlertView showWithTitle:NSLocalizedString(@"Error setting status", @"Error setting status") 
																  message:error.localizedDescription 
															  buttonTitle:NSLocalizedString(@"OK", @"OK")];	
										  }];
}

#pragma mark - SBSectionHeaderViewDelegate
- (void)sectionHeaderView:(SBSectionHeaderView*)sectionHeaderView sectionOpened:(NSInteger)sectionOpened {	
	sectionHeaderView.state = SBSectionHeaderStateOpen;
    /*
     Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
     */
	NSArray *keys = [_seasons allKeys];
	NSString *sectionKey = [keys objectAtIndex:sectionOpened];
	
    NSInteger countOfRowsToInsert = [[_seasons objectForKey:sectionKey] count];
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
    }
    
    // Apply the updates.
    [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)sectionHeaderView:(SBSectionHeaderView*)sectionHeaderView sectionClosed:(NSInteger)sectionClosed {
    sectionHeaderView.state = SBSectionHeaderStateClosed;
	
    /*
     Create an array of the index paths of the rows in the section that was closed, then delete those rows from the table view.
     */
	NSInteger countOfRowsToDelete = [self.tableView numberOfRowsInSection:sectionClosed];
    
    if (countOfRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:sectionClosed]];
        }
        [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
