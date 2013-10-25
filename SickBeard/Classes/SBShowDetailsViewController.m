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
#import "EpisodeCell.h"
#import "SBShowDetailsHeaderView.h"
#import "SBSectionHeaderView.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "SBServer.h"
#import "SBCommandBuilder.h"

@interface SBShowDetailsViewController () <SBSectionHeaderViewDelegate, UIGestureRecognizerDelegate> {
	struct {
		int menuIsShowing:1;
		int menuIsHiding:1;
	} _menuFlags;
	NSIndexPath *_menuIndexPath;
}

- (void)changeEpisodeStatus:(EpisodeStatus)status;
@property (nonatomic, strong) OrderedDictionary *seasons;
@property (nonatomic, strong) NSMutableArray *sectionHeaders;
@property (nonatomic, strong) NSOperationQueue *batchQueue;

@end

@implementation SBShowDetailsViewController

@synthesize currentEpisodeIndexPath = _currentEpisodeIndexPath;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"EpisodeDetailsSegue"]) {
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		SBEpisodeDetailsViewController *vc = segue.destinationViewController;
		vc.dataSource = self;
		
		NSArray *seasonKeys = [_seasons allKeys];
		SBEpisode *episode = _seasons[seasonKeys[indexPath.section]][indexPath.row];
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
	self.title = self.show.showName;
	
	UINib *headerNib = [UINib nibWithNibName:@"SBShowDetailsHeaderView" bundle:nil];
	[headerNib instantiateWithOwner:self options:nil];
	self.detailsHeaderView.showNameLabel.text = self.show.showName;
	
	[self.detailsHeaderView.showImageView setImageWithURL:[self.apiClient posterURLForTVDBID:self.show.tvdbID]
										 placeholderImage:nil];
	self.detailsHeaderView.networkLabel.text = self.show.network;
	
	self.detailsHeaderView.statusLabel.text = [SBShow showStatusAsString:self.show.status];
	if (self.show.status == ShowStatusContinuing) {
		self.detailsHeaderView.statusLabel.textColor = RGBCOLOR(21, 93, 45);
	}
	else if (self.show.status == ShowStatusEnded) {
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

- (BOOL)shouldAutorotate {
	return NO;
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

#pragma mark - Accessors
- (NSOperationQueue *)batchQueue {
	if (!_batchQueue) {
		_batchQueue = [[NSOperationQueue alloc] init];
		_batchQueue.maxConcurrentOperationCount = 5;
	}
	
	return _batchQueue;
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
	UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[searchButton setTitle:@"Search" forState:UIControlStateNormal];
	[searchButton sizeToFit];
	[searchButton addTarget:self action:@selector(searchForMultipleEpisodes:) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *setStatusButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[setStatusButton setTitle:@"Set Status" forState:UIControlStateNormal];
	[setStatusButton sizeToFit];
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
	
	[self.apiClient runCommand:SickBeardCommandSeasons
									   parameters:@{@"tvdbid": self.show.tvdbID}
										  success:^(NSURLSessionDataTask *task, id JSON) {
											  NSString *result = JSON[@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  NSDictionary *dataDict = JSON[@"data"];
												  
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
													  
													  NSDictionary *seasonDict = dataDict[seasonNumber];
													  
													  for (NSString *episodeNumber in [seasonDict allKeys]) {
														  SBEpisode *episode = [SBEpisode itemWithDictionary:seasonDict[episodeNumber]];
														  
														  episode.show = self.show;
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
													  
													  _seasons[seasonNumber] = episodes;
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
											  }
											  else {
												  [self finishDataLoad:nil];
												  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving shows", @"Error retrieving shows") 
																	  message:JSON[@"message"] 
																  buttonTitle:NSLocalizedString(@"OK", @"OK")];
											  }
										  }
										  failure:^(NSURLSessionDataTask *task, NSError *error) {
											  [self finishDataLoad:error];
											  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving show information", @"Error retrieving show information") 
																  message:error.localizedDescription 
															  buttonTitle:NSLocalizedString(@"OK", @"OK")];		
										  }];
}

#pragma mark - Batch Actions
- (void)searchForMultipleEpisodes:(UIButton *)sender {
	if (self.tableView.indexPathsForSelectedRows.count == 0) {
		[PRPAlertView showWithTitle:@"Cannot perform search"
							message:@"Please select at least one episode."
						buttonTitle:@"OK"];
		return;
	}
	
	SBServer *currentServer = [NSUserDefaults standardUserDefaults].server;
	NSMutableArray *operations = [NSMutableArray arrayWithCapacity:self.tableView.indexPathsForSelectedRows.count];
	
	for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
		NSArray *keys = [_seasons allKeys];
		NSString *sectionKey = keys[indexPath.section];
		NSArray *episodes = _seasons[sectionKey];
		
		SBEpisode *episode = episodes[indexPath.row];

		NSDictionary *params = @{@"tvdbid": self.show.tvdbID,
								@"season": @(episode.season),
								@"episode": @(episode.number)};
		
		NSString *urlPath = [SBCommandBuilder URLForCommand:SickBeardCommandEpisodeSearch
											  server:currentServer
											  params:params];

		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlPath]];
		[operations addObject:[[AFHTTPRequestOperation alloc] initWithRequest:request]];
	}
	
	[self setEditing:NO animated:YES];

	[TSMessage showNotificationWithTitle:[NSString stringWithFormat:@"Searching for %d episodes", operations.count]
									type:TSMessageNotificationTypeMessage];
	
	
	NSArray *batch = [AFHTTPRequestOperation batchOfRequestOperations:operations
														progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
										   
														} completionBlock:^(NSArray *operations) {
															[TSMessage showNotificationWithTitle:@"Finished searching for episodes."
																							type:TSMessageNotificationTypeMessage];
														}];
	
	[self.batchQueue addOperations:batch waitUntilFinished:NO];
}

- (void)setStatusForMultipleEpisodes:(UIButton *)sender {
	UIMenuController *menu = [UIMenuController sharedMenuController];
	UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:[SBEpisode episodeStatusAsString:EpisodeStatusWanted] action:@selector(setEpisodeStatusToWantedBatch)];
	UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:[SBEpisode episodeStatusAsString:EpisodeStatusSkipped] action:@selector(setEpisodeStatusToSkippedBatch)];
	UIMenuItem *item3 = [[UIMenuItem alloc] initWithTitle:[SBEpisode episodeStatusAsString:EpisodeStatusArchived] action:@selector(setEpisodeStatusToArchivedBatch)];
	UIMenuItem *item4 = [[UIMenuItem alloc] initWithTitle:[SBEpisode episodeStatusAsString:EpisodeStatusIgnored] action:@selector(setEpisodeStatusToIgnoredBatch)];
	
	menu.menuItems = @[item1, item2, item3, item4];

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
	if (self.tableView.indexPathsForSelectedRows.count == 0) {
		[PRPAlertView showWithTitle:@"Cannot change episode status"
							message:@"Please select at least one episode."
						buttonTitle:@"OK"];
		return;
	}
	
	SBServer *currentServer = [NSUserDefaults standardUserDefaults].server;
	NSMutableArray *operations = [NSMutableArray arrayWithCapacity:self.tableView.indexPathsForSelectedRows.count];
	NSString *statusString = [[SBEpisode episodeStatusAsString:status] lowercaseString];

	for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
		NSArray *keys = [_seasons allKeys];
		NSString *sectionKey = keys[indexPath.section];
		NSArray *episodes = _seasons[sectionKey];
		SBEpisode *episode = episodes[indexPath.row];
				
		NSDictionary *params = @{@"tvdbid": episode.show.tvdbID,
								@"season": @(episode.season),
								@"episode": @(episode.number),
								@"status": statusString};
		
		NSString *urlPath = [SBCommandBuilder URLForCommand:SickBeardCommandEpisodeSetStatus
													 server:currentServer
													 params:params];
		
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlPath]];
		[operations addObject:[[AFHTTPRequestOperation alloc] initWithRequest:request]];
	}
	
	[TSMessage showNotificationWithTitle:[NSString stringWithFormat:@"Attempting to set %d episodes to %@", operations.count, statusString]
									type:TSMessageNotificationTypeMessage];

	[self setEditing:NO animated:YES];

    NSArray *batch = [AFHTTPRequestOperation batchOfRequestOperations:operations
									   progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
										   
									   } completionBlock:^(NSArray *operations) {
										   [TSMessage showNotificationWithTitle:[NSString stringWithFormat:@"Episode statuses set to %@.", statusString]
																		   type:TSMessageNotificationTypeMessage];
									   }];
	
	[self.batchQueue addOperations:batch waitUntilFinished:NO];
}

#pragma mark - SBEpisodeDetailsDataSource
- (SBEpisode*)nextEpisode {
	SBEpisode *episode = nil;

	NSArray *seasonKeys = [_seasons allKeys];

	if (self.currentEpisodeIndexPath.section == seasonKeys.count) {
		return nil;
	}

	NSArray *seasonEpisodes = _seasons[seasonKeys[self.currentEpisodeIndexPath.section]];
	
	NSIndexPath *nextEpisodeIndexPath = [NSIndexPath indexPathForRow:self.currentEpisodeIndexPath.row - 1 inSection:self.currentEpisodeIndexPath.section];
	
	if (nextEpisodeIndexPath.row >= 0) {	// check if the next episode lies within the current season
		episode = seasonEpisodes[nextEpisodeIndexPath.row];
	}
	else {	// move the previous season		
		if (nextEpisodeIndexPath.section - 1 >= 0) {	// check if the next season lies within the bounds of the number of seasons
			seasonEpisodes = _seasons[seasonKeys[self.currentEpisodeIndexPath.section - 1]];
			nextEpisodeIndexPath = [NSIndexPath indexPathForRow:seasonEpisodes.count - 1 inSection:self.currentEpisodeIndexPath.section - 1];
			episode = seasonEpisodes[nextEpisodeIndexPath.row];
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
	
	NSArray *seasonEpisodes = _seasons[seasonKeys[self.currentEpisodeIndexPath.section]];
	
	NSIndexPath *previousEpisodeIndexPath = [NSIndexPath indexPathForRow:self.currentEpisodeIndexPath.row + 1 inSection:self.currentEpisodeIndexPath.section];

	if (previousEpisodeIndexPath.row < seasonEpisodes.count) {	// check if the previous episode lies within the current season
		episode = seasonEpisodes[previousEpisodeIndexPath.row];
	}
	else {	// move the next season
		previousEpisodeIndexPath = [NSIndexPath indexPathForRow:0 inSection:self.currentEpisodeIndexPath.section + 1];
		
		if (previousEpisodeIndexPath.section < seasonKeys.count) {	// check if the previous season lies within the bounds of the number of seasons
			seasonEpisodes = _seasons[seasonKeys[previousEpisodeIndexPath.section]];
			episode = seasonEpisodes[previousEpisodeIndexPath.row];
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
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return [[_seasons allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *title = @"";
	
	NSArray *keys = [_seasons allKeys];
	NSString *sectionKey = keys[section];
	
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

	id header = _sectionHeaders[section];
	
	if (header == [NSNull null]) {
		SBSectionHeaderView *sectionHeader = [[SBSectionHeaderView alloc] init];
		sectionHeader.section = section;
		sectionHeader.delegate = self;
		sectionHeader.sectionLabel.text = title;

		_sectionHeaders[section] = sectionHeader;
		header = sectionHeader;
	}
	return header;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 25.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *keys = [_seasons allKeys];
	NSString *sectionKey = keys[section];
	
	SBSectionHeaderView *headerView = (SBSectionHeaderView *)[self tableView:tableView viewForHeaderInSection:section];
	
	return headerView.state == SBSectionHeaderStateOpen ? [_seasons[sectionKey] count] : 0;
}


- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	EpisodeCell *cell = (EpisodeCell*)[tv dequeueReusableCellWithIdentifier:@"EpisodeCell"];
	
	NSArray *keys = [_seasons allKeys];
	NSString *sectionKey = keys[indexPath.section];
	NSArray *episodes = _seasons[sectionKey];
	
	SBEpisode *episode = episodes[indexPath.row];
	
	cell.episodeNameLabel.text = episode.name;
	cell.airdateLabel.text = episode.airDate ? [episode.airDate displayString] : NSLocalizedString(@"Unknown Air Date", @"Unknown Air Date");
	cell.badgeView.textLabel.text = [SBEpisode episodeStatusAsString:episode.status];
	
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
	cell.badgeView.highlightedBadgeColor = badgeColor;
	
	UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
	gesture.delegate = self;
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

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	return self.editing == NO;
}

#pragma mark - Menu Actions
- (void)showMenu:(UIGestureRecognizer*)gesture {
	if (gesture.state == UIGestureRecognizerStateBegan) {
		[gesture.view becomeFirstResponder];
		
		_menuIndexPath = [self.tableView indexPathForRowAtPoint:[gesture locationInView:self.tableView]];
		
		NSArray *keys = [_seasons allKeys];
		NSString *sectionKey = keys[_menuIndexPath.section];
		NSArray *episodes = _seasons[sectionKey];
		SBEpisode *episode = episodes[_menuIndexPath.row];
		
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
	NSString *sectionKey = keys[_menuIndexPath.section];
	NSArray *episodes = _seasons[sectionKey];
	SBEpisode *episode = episodes[_menuIndexPath.row];
	
	NSDictionary *params = @{@"tvdbid": self.show.tvdbID,
							@"season": @(episode.season),
							@"episode": @(episode.number)};
	
	[TSMessage showNotificationWithTitle:NSLocalizedString(@"Searching for episode", @"Searching for episode")
									type:TSMessageNotificationTypeMessage];
	
	[self.apiClient runCommand:SickBeardCommandEpisodeSearch
									   parameters:params 
										  success:^(NSURLSessionDataTask *task, id JSON) {
											  NSString *result = JSON[@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  [TSMessage showNotificationWithTitle:NSLocalizedString(@"Episode found and is downloading", @"Episode found and is downloading")
																				  type:TSMessageNotificationTypeSuccess];
												  [self loadData:NO];
											  }
											  else {
												  [TSMessage showNotificationWithTitle:JSON[@"mesage"]
																				  type:TSMessageNotificationTypeError];
											  }
										  }
										  failure:^(NSURLSessionDataTask *task, NSError *error) {
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
	
	menu.menuItems = @[item1, item2, item3, item4];

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
	NSString *sectionKey = keys[_menuIndexPath.section];
	NSArray *episodes = _seasons[sectionKey];
	SBEpisode *episode = episodes[_menuIndexPath.row];

	NSString *statusString = [[SBEpisode episodeStatusAsString:status] lowercaseString];
	
	NSDictionary *params = @{@"tvdbid": episode.show.tvdbID, 
							@"season": @(episode.season),
							@"episode": @(episode.number),
							@"status": statusString};
	
	[TSMessage showNotificationWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Setting episode status to %@", @"Setting episode status to %@"), statusString]
																type:TSMessageNotificationTypeMessage];
	
	[self.apiClient runCommand:SickBeardCommandEpisodeSetStatus
									   parameters:params 
										  success:^(NSURLSessionDataTask *task, id JSON) {
											  NSString *result = JSON[@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  [TSMessage showNotificationWithTitle:NSLocalizedString(@"Status successfully set!", @"Status successfully set!")
																											  type:TSMessageNotificationTypeSuccess];
												  [self loadData:NO];
											  }
											  else {
												  [TSMessage showNotificationWithTitle:JSON[@"message"]
																											  type:TSMessageNotificationTypeError];
											  }
										  }
										  failure:^(NSURLSessionDataTask *task, NSError *error) {
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
	NSString *sectionKey = keys[sectionOpened];
	
    NSInteger countOfRowsToInsert = [_seasons[sectionKey] count];
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
    }
    
    // Apply the updates.
    [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationFade];
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
        [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
