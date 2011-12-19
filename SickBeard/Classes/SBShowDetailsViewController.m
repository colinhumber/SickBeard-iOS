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
#import "NSDate+Utilities.h"
#import "SVModalWebViewController.h"
#import "EpisodeCell.h"
#import "SBShowDetailsHeaderView.h"
#import "SBSectionHeaderView.h"

@interface SBShowDetailsViewController ()
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
		
		NSArray *seasonKeys = [seasons allKeys];
		SBEpisode *episode = [[seasons objectForKey:[seasonKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
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
	
	seasons = [[OrderedDictionary alloc] init];
	self.title = show.showName;
	
	UINib *headerNib = [UINib nibWithNibName:@"SBShowDetailsHeaderView" bundle:nil];
	[headerNib instantiateWithOwner:self options:nil];
	self.detailsHeaderView.showNameLabel.text = show.showName;
	[self.detailsHeaderView.showImageView setImageWithURL:[[SickbeardAPIClient sharedClient] posterURLForTVDBID:show.tvdbID]];
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
- (void)loadData {
	[SVProgressHUD showWithStatus:NSLocalizedString(@"Loading show details", @"Loading show details")];
	
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
										  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
											  [self finishDataLoad:error];
											  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving show information", @"Error retrieving show information") 
																  message:error.localizedDescription 
															  buttonTitle:NSLocalizedString(@"OK", @"OK")];		
											  [self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
										  }];
}

#pragma mark - Actions
- (IBAction)showActions {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" 
															 delegate:self 
													cancelButtonTitle:nil 
											   destructiveButtonTitle:nil 
													otherButtonTitles:NSLocalizedString(@"Search iTunes", @"Search iTunes"), NSLocalizedString(@"View on TheTVDB", @"View on TheTVDB"), nil];
	
	if (show.tvRageID.length > 0) {
		[actionSheet addButtonWithTitle:NSLocalizedString(@"View on TVRage", @"View on TVRage")];
	}
	
	[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel")];
	actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
	
	[actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != actionSheet.cancelButtonIndex) {
		NSString *urlPath = @"";
		
		if (buttonIndex == 0) {
			urlPath = [SBGlobal itunesLinkForShow:show.showName];
		}
		else if (buttonIndex == 1) {
			urlPath = [NSString stringWithFormat:kTVDBLinkFormat, show.tvdbID];
		}
		else if (buttonIndex == 2) {
			urlPath = [NSString stringWithFormat:kTVRageLinkFormat, show.tvRageID];		
		}
		
		if ([urlPath rangeOfString:@"itms://"].location == NSNotFound) {
			SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:urlPath];
			webViewController.toolbar.tintColor = nil;
			webViewController.toolbar.barStyle = UIBarStyleBlack;
			webViewController.availableActions = SVWebViewControllerAvailableActionsCopyLink | SVWebViewControllerAvailableActionsMailLink | SVWebViewControllerAvailableActionsOpenInSafari;
			[self presentViewController:webViewController animated:YES completion:nil];
		}
		else {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
		}
	}
}


#pragma mark - SBEpisodeDetailsDataSource
- (SBEpisode*)nextEpisode {
	SBEpisode *episode = nil;

	NSArray *seasonKeys = [seasons allKeys];

	if (self.currentEpisodeIndexPath.section == seasonKeys.count) {
		return nil;
	}

	NSArray *seasonEpisodes = [seasons objectForKey:[seasonKeys objectAtIndex:self.currentEpisodeIndexPath.section]];
	
	NSIndexPath *nextEpisodeIndexPath = [NSIndexPath indexPathForRow:self.currentEpisodeIndexPath.row - 1 inSection:self.currentEpisodeIndexPath.section];
	
	if (nextEpisodeIndexPath.row >= 0) {	// check if the next episode lies within the current season
		episode = [seasonEpisodes objectAtIndex:nextEpisodeIndexPath.row];
	}
	else {	// move the previous season		
		if (nextEpisodeIndexPath.section - 1 >= 0) {	// check if the next season lies within the bounds of the number of seasons
			seasonEpisodes = [seasons objectForKey:[seasonKeys objectAtIndex:self.currentEpisodeIndexPath.section - 1]];
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
	
	NSArray *seasonKeys = [seasons allKeys];
	
	if (self.currentEpisodeIndexPath.section == seasonKeys.count) {
		return nil;
	}
	
	NSArray *seasonEpisodes = [seasons objectForKey:[seasonKeys objectAtIndex:self.currentEpisodeIndexPath.section]];
	
	NSIndexPath *previousEpisodeIndexPath = [NSIndexPath indexPathForRow:self.currentEpisodeIndexPath.row + 1 inSection:self.currentEpisodeIndexPath.section];

	if (previousEpisodeIndexPath.row < seasonEpisodes.count) {	// check if the previous episode lies within the current season
		episode = [seasonEpisodes objectAtIndex:previousEpisodeIndexPath.row];
	}
	else {	// move the next season
		previousEpisodeIndexPath = [NSIndexPath indexPathForRow:0 inSection:self.currentEpisodeIndexPath.section + 1];
		
		if (previousEpisodeIndexPath.section < seasonKeys.count) {	// check if the previous season lies within the bounds of the number of seasons
			seasonEpisodes = [seasons objectForKey:[seasonKeys objectAtIndex:previousEpisodeIndexPath.section]];
			episode = [seasonEpisodes objectAtIndex:previousEpisodeIndexPath.row];
		}
	}
	
	if (episode) {
		self.currentEpisodeIndexPath = previousEpisodeIndexPath;
	}
	
	return episode;
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
		title = NSLocalizedString(@"Specials", @"Specials");
	}
	else {
		title = [NSString stringWithFormat:NSLocalizedString(@"Season %@", @"Season %@"), sectionKey];
	}
	
	return title;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString *title = [self tableView:tableView titleForHeaderInSection:section];

	SBSectionHeaderView *header = [[SBSectionHeaderView alloc] init];
	header.sectionLabel.text = title;
	return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 50;
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
	cell.airdateLabel.text = episode.airDate ? [episode.airDate displayString] : NSLocalizedString(@"Unknown Air Date", @"Unknown Air Date");
	cell.badgeView.text = [[SBEpisode episodeStatusAsString:episode.status] substringToIndex:1];
	
	UIColor *badgeColor = nil;
	
	switch (episode.status) {
		case EpisodeStatusWanted:
			badgeColor = RGBCOLOR(231, 147, 0);
			break;
			
		case EpisodeStatusDownloaded:
		case EpisodeStatusSnatched:
			badgeColor = RGBCOLOR(21, 93, 45);
			break;
			
		case EpisodeStatusSkipped:
			badgeColor = RGBCOLOR(202, 50, 56);
			break;
			
		default:
			badgeColor = [UIColor darkGrayColor];
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
	
	[self performSegueWithIdentifier:@"EpisodeDetailsSegue" sender:nil];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Menu Actions
- (void)showMenu:(UIGestureRecognizer*)gesture {
	if (gesture.state == UIGestureRecognizerStateBegan) {
		[gesture.view becomeFirstResponder];
		
		menuIndexPath = [self.tableView indexPathForRowAtPoint:[gesture locationInView:self.tableView]];
		
		UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Search", @"Search") action:@selector(searchForEpisode)];
		UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Set Status", @"Set Status") action:@selector(setEpisodeStatus)];
		
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
	
	[SVProgressHUD showWithStatus:NSLocalizedString(@"Searching for episode", @"Searching for episode")];
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandEpisodeSearch 
									   parameters:params 
										  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  [SVProgressHUD dismissWithSuccess:NSLocalizedString(@"Episode found and is downloading", @"Episode found and is downloading") 
																		 afterDelay:2];
												  [self loadData];
											  }
											  else {
												  [SVProgressHUD dismissWithError:[JSON objectForKey:@"message"] afterDelay:2];
											  }
										  }
										  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
											  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving shows", @"Error retrieving shows") 
																  message:[NSString stringWithFormat:NSLocalizedString(@"Could not retreive shows \n%@",@"Could not retreive shows \n%@" ), 
																		   error.localizedDescription] 
															  buttonTitle:NSLocalizedString(@"OK", @"OK")];	
											  [SVProgressHUD dismiss];
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
	
	[SVProgressHUD showWithStatus:[NSString stringWithFormat:NSLocalizedString(@"Setting episode status to %@", @"Setting episode status to %@"), statusString]];
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandEpisodeSetStatus 
									   parameters:params 
										  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  [SVProgressHUD dismissWithSuccess:NSLocalizedString(@"Status successfully set!", @"Status successfully set!") 
																		 afterDelay:2];
												  [self loadData];
											  }
											  else {
												  [SVProgressHUD dismissWithError:[JSON objectForKey:@"message"] afterDelay:2];
											  }
										  }
										  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
											  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving shows", @"Error retrieving shows") 
																  message:[NSString stringWithFormat:@"Could not retreive shows \n%@", error.localizedDescription] 
															  buttonTitle:NSLocalizedString(@"OK", @"OK")];	
											  [SVProgressHUD dismiss];
										  }];
}

@end
