//
//  SBShowDetailsViewController.m
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBShowDetailsViewController.h"
#import "SickbeardAPIClient.h"
#import "SBShow.h"
#import "PRPAlertView.h"
#import "SBEpisode.h"
#import "OrderedDictionary.h"
#import "SBEpisodeDetailsViewController.h"
#import "NSDate+Utilities.h"
#import "SVModalWebViewController.h"
#import "EpisodeCell.h"
#import "SBShowDetailsHeaderView.h"

@interface SBShowDetailsViewController ()
- (void)changeEpisodeStatus:(EpisodeStatus)status;
@end

@implementation SBShowDetailsViewController

@synthesize show;
@synthesize detailsHeaderView;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"EpisodeDetailsSegue"]) {
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		SBEpisodeDetailsViewController *vc = segue.destinationViewController;
	
		NSArray *seasonKeys = [seasons allKeys];
		SBEpisode *episode = [[seasons objectForKey:[seasonKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
		vc.episode = episode;
	}
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
	
	_menuFlags.menuIsShowing = NO;
	_menuFlags.menuIsHiding = NO;
	
	[TestFlight passCheckpoint:@"Viewed show details"];
	
	seasons = [[OrderedDictionary alloc] init];
	self.title = show.showName;
	
	UINib *headerNib = [UINib nibWithNibName:@"SBShowDetailsHeaderView" bundle:nil];
	[headerNib instantiateWithOwner:self options:nil];
	self.detailsHeaderView.showNameLabel.text = show.showName;
	[self.detailsHeaderView.showImageView setImageWithURL:[[SickbeardAPIClient sharedClient] posterURLForTVDBID:show.tvdbID]];
	self.detailsHeaderView.networkLabel.text = show.network;
	self.tableView.tableHeaderView = self.detailsHeaderView;
	
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

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self loadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Notification Handlers

- (void)menuControllerWillHide:(NSNotification *)notification {
	_menuFlags.menuIsHiding = YES;
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)menuControllerDidHide:(NSNotification*)notification {
	_menuFlags.menuIsShowing = NO;
}

- (void)menuControllerWillShow:(NSNotification *)notification {
	self.tableView.scrollEnabled = NO;
}

- (void)menuControllerDidShow:(NSNotification *)notification {
	_menuFlags.menuIsShowing = YES;
	self.tableView.scrollEnabled = YES;
}

#pragma mark - Loading
- (void)loadData {
	[SVProgressHUD showWithStatus:@"Loading show details"];
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandSeasons
									   parameters:[NSDictionary dictionaryWithObject:show.tvdbID forKey:@"tvdbid"]
										  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
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
													  
													  [seasons setObject:episodes forKey:seasonNumber];
													  
												  }

												  self.detailsHeaderView.episodeCountLabel.text = [NSString stringWithFormat:@"%d/%d", totalDownloadedEpisodes, totalEpisodes];
												  
												  float progress = 0;
												  if (totalEpisodes > 0) {
													  progress = (float)totalDownloadedEpisodes/totalEpisodes;
												  }
												  self.detailsHeaderView.progressBar.progress = progress;

												  [self finishDataLoad:nil];
												  [self.tableView reloadData];
												  [self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
											  }
											  else {
												  [self finishDataLoad:nil];
												  [PRPAlertView showWithTitle:@"Error retrieving shows" 
																	  message:[JSON objectForKey:@"message"] 
																  buttonTitle:@"OK"];
												  [self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
											  }
										  }
										  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
											  [self finishDataLoad:error];
											  [PRPAlertView showWithTitle:@"Error retrieving show information" 
																  message:error.localizedDescription 
															  buttonTitle:@"OK"];		
											  [self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
										  }];
}

#pragma mark - Actions
- (IBAction)showActions {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" 
															 delegate:self 
													cancelButtonTitle:nil 
											   destructiveButtonTitle:nil 
													otherButtonTitles:@"View on TheTVDB", nil];
	
	if (show.tvRageID.length > 0) {
		[actionSheet addButtonWithTitle:@"View on TVRage"];
	}
	
	[actionSheet addButtonWithTitle:@"Cancel"];
	actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
	
	[actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != actionSheet.cancelButtonIndex) {
		NSString *urlPath = @"";
		
		if (buttonIndex == 0) {
			urlPath = [NSString stringWithFormat:kTVDBLinkFormat, show.tvdbID];
		}
		else if (buttonIndex == 1) {
			urlPath = [NSString stringWithFormat:kTVRageLinkFormat, show.tvRageID];		
		}
	
		SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:urlPath];
		webViewController.availableActions = SVWebViewControllerAvailableActionsCopyLink | SVWebViewControllerAvailableActionsMailLink | SVWebViewControllerAvailableActionsOpenInSafari;
		[self presentViewController:webViewController animated:YES completion:nil];
	}
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return [[seasons allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *title = @"";
	
	NSArray *keys = [seasons allKeys];
	NSString *sectionKey = [keys objectAtIndex:section];
	
	if ([sectionKey isEqualToString:@"0"]) {
		title = @"Specials";
	}
	else {
		title = [NSString stringWithFormat:@"Season %@", sectionKey];
	}
	
	return title;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString *title = [self tableView:tableView titleForHeaderInSection:section];
	UIView *headerView = nil;
	
	if (title) {
		headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 22)];
		headerView.backgroundColor = [UIColor clearColor];
		
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 310, 22)];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.text = title;
		titleLabel.font = [UIFont boldSystemFontOfSize:17];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.shadowColor = [UIColor blackColor];
		titleLabel.shadowOffset = CGSizeMake(0, 1);
		[headerView addSubview:titleLabel];
	}
	
	return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *keys = [seasons allKeys];
	NSString *sectionKey = [keys objectAtIndex:section];
	
	return [[seasons objectForKey:sectionKey] count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	EpisodeCell *cell = (EpisodeCell*)[tv dequeueReusableCellWithIdentifier:@"EpisodeCell"];
	
	NSArray *keys = [seasons allKeys];
	NSString *sectionKey = [keys objectAtIndex:indexPath.section];
	NSArray *episodes = [seasons objectForKey:sectionKey];
	
	SBEpisode *episode = [episodes objectAtIndex:indexPath.row];
	
	cell.episodeNameLabel.text = episode.name;
	cell.airdateLabel.text = episode.airDate ? [episode.airDate displayString] : @"Unknown Air Date";
	cell.badgeView.text = [SBEpisode episodeStatusAsString:episode.status];
	
	UIColor *badgeColor = nil;
	
	switch (episode.status) {
		case EpisodeStatusWanted:
			badgeColor = RGBCOLOR(231, 147, 0);
			break;
			
		case EpisodeStatusDownloaded:
			badgeColor = RGBCOLOR(50, 151, 56);
			break;
			
		case EpisodeStatusSkipped:
			badgeColor = RGBCOLOR(202, 50, 56);
			break;
			
		default:
			badgeColor = [UIColor darkGrayColor];
			break;
	}
	cell.badgeView.badgeColor = badgeColor;
	
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
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self performSegueWithIdentifier:@"EpisodeDetailsSegue" sender:nil];
}

#pragma mark - Menu Actions
- (void)showMenu:(UIGestureRecognizer*)gesture {
	if (gesture.state == UIGestureRecognizerStateBegan) {
		[gesture.view becomeFirstResponder];
		
		menuIndexPath = [self.tableView indexPathForRowAtPoint:[gesture locationInView:self.tableView]];
		
		UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:@"Search" action:@selector(searchForEpisode)];
		UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:@"Set Status" action:@selector(setEpisodeStatus)];
		
		UIMenuController *menu = [UIMenuController sharedMenuController];
		menu.menuItems = [NSArray arrayWithObjects:item1, item2, nil];
		[menu setTargetRect:gesture.view.frame inView:gesture.view.superview];
		[menu setMenuVisible:YES animated:YES];
	
		[self.tableView selectRowAtIndexPath:menuIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
}

- (void)searchForEpisode {
	NSArray *keys = [seasons allKeys];
	NSString *sectionKey = [keys objectAtIndex:menuIndexPath.section];
	NSArray *episodes = [seasons objectForKey:sectionKey];
	SBEpisode *episode = [episodes objectAtIndex:menuIndexPath.row];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							show.tvdbID, @"tvdbid", 
							[NSNumber numberWithInt:episode.season], @"season",
							[NSNumber numberWithInt:episode.number], @"episode", nil];
	
	[SVProgressHUD showWithStatus:@"Searching for episode"];
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandEpisodeSearch 
									   parameters:params 
										  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  [SVProgressHUD dismissWithSuccess:@"Episode found and is downloading" afterDelay:2];
												  [self loadData];
											  }
											  else {
												  [SVProgressHUD dismissWithError:[JSON objectForKey:@"message"] afterDelay:2];
											  }
										  }
										  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
											  [PRPAlertView showWithTitle:@"Error retrieving shows" 
																  message:[NSString stringWithFormat:@"Could not retreive shows \n%@", error.localizedDescription] 
															  buttonTitle:@"OK"];	
											  [SVProgressHUD dismiss];
										  }];
}

- (void)setEpisodeStatus {
	UIMenuController *menu = [UIMenuController sharedMenuController];
	UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:@"Wanted" action:@selector(setEpisodeStatusToWanted)];
	UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:@"Skipped" action:@selector(setEpisodeStatusToSkipped)];
	UIMenuItem *item3 = [[UIMenuItem alloc] initWithTitle:@"Archived" action:@selector(setEpisodeStatusToArchived)];
	UIMenuItem *item4 = [[UIMenuItem alloc] initWithTitle:@"Ignored" action:@selector(setEpisodeStatusToIgnored)];
	
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
	NSArray *keys = [seasons allKeys];
	NSString *sectionKey = [keys objectAtIndex:menuIndexPath.section];
	NSArray *episodes = [seasons objectForKey:sectionKey];
	SBEpisode *episode = [episodes objectAtIndex:menuIndexPath.row];

	NSString *statusString = [[SBEpisode episodeStatusAsString:status] lowercaseString];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							episode.show.tvdbID, @"tvdbid", 
							[NSNumber numberWithInt:episode.season], @"season",
							[NSNumber numberWithInt:episode.number], @"episode",
							statusString, @"status", nil];
	
	[SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Setting episode status to %@", statusString]];
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandEpisodeSetStatus 
									   parameters:params 
										  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  [SVProgressHUD dismissWithSuccess:@"Status successfully set!" afterDelay:2];
												  [self loadData];
											  }
											  else {
												  [SVProgressHUD dismissWithError:[JSON objectForKey:@"message"] afterDelay:2];
											  }
										  }
										  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
											  [PRPAlertView showWithTitle:@"Error retrieving shows" 
																  message:[NSString stringWithFormat:@"Could not retreive shows \n%@", error.localizedDescription] 
															  buttonTitle:@"OK"];	
											  [SVProgressHUD dismiss];
										  }];
}

@end
