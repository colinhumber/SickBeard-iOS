//
//  SBEpisodesViewController.m
//  SickBeard
//
//  Created by Colin Humber on 8/26/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBEpisodesViewController.h"
#import "SBEpisodeDetailsViewController.h"
#import "SickbeardAPIClient.h"
#import "NSUserDefaults+SickBeard.h"
#import "OrderedDictionary.h"
#import "SBComingEpisode.h"
#import "PRPAlertView.h"
#import "NSDate+Utilities.h"
#import "ComingEpisodeCell.h"
#import "SBSectionHeaderView.h"
#import "SVProgressHUD.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface SBEpisodesViewController () {
	OrderedDictionary *comingEpisodes;
	
	struct {
		int menuIsShowing:1;
		int menuIsHiding:1;
	} _menuFlags;
	NSIndexPath *menuIndexPath;
}

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

- (void)changeEpisodeStatus:(EpisodeStatus)status;

@end



@implementation SBEpisodesViewController

@synthesize selectedIndexPath;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"EpisodeDetailsSegue"]) {
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		SBEpisodeDetailsViewController *vc = segue.destinationViewController;
		
		NSArray *keys = [comingEpisodes allKeys];
		NSString *sectionKey = keys[indexPath.section];
		
		SBComingEpisode *episode = comingEpisodes[sectionKey][indexPath.row];

		vc.episode = episode;
	}
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.tableView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.height + [UIApplication sharedApplication].statusBarFrame.size.height, 0, self.navigationController.toolbar.height, 0);
	
	_menuFlags.menuIsShowing = NO;
	_menuFlags.menuIsHiding = NO;
		
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

- (void)viewWillAppear:(BOOL)animated {
	[TestFlight passCheckpoint:@"Viewed coming episodes"];
	
	[super viewWillAppear:animated];
	
	if ([self.tableView.dataSource numberOfSectionsInTableView:self.tableView] > 0) {
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
	}
	else {
		if ([NSUserDefaults standardUserDefaults].serverHasBeenSetup) {
			if (!comingEpisodes) {
				[comingEpisodes removeAllObjects];
				[self loadData];
			}
		}		
	}
}

- (BOOL)shouldAutorotate {
	return NO;
}

#pragma mark - Actions
- (IBAction)refresh:(id)sender {
	[self loadData];
}

#pragma mark - Loading
- (void)loadData {
	[super loadData];
	
	[SVProgressHUD showWithStatus:NSLocalizedString(@"Loading upcoming episodes", @"Loading upcoming episodes")];
	
	[self.apiClient runCommand:SickBeardCommandComingEpisodes
									   parameters:nil 
										  success:^(NSURLSessionDataTask *task, id JSON) {
											  NSString *result = JSON[@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  comingEpisodes = [[OrderedDictionary alloc] init];
												  
												  NSMutableArray *episodes = [NSMutableArray array];
												  NSDictionary *dataDict = JSON[@"data"];
												  
												  for (NSString *key in [dataDict allKeys]) {
													  for (NSDictionary *epDict in dataDict[key]) {
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
													  if ([episode.airDate isToday]) {
														  [today addObject:episode];
													  }
													  else if ([episode.airDate isThisWeek]) {
														  [thisWeek addObject:episode];
													  }
													  else if ([episode.airDate isNextWeek]) {
														  [nextWeek addObject:episode];
													  }
													  else if ([episode.airDate isEarlierThanDate:[NSDate date]]) {
														  [past addObject:episode];
													  }
													  else {
														  [future addObject:episode];
													  }
												  }
												  
												  if (past.count) comingEpisodes[@"Past"] = past;
												  if (today.count) comingEpisodes[@"Today"] = today;
												  if (thisWeek.count) comingEpisodes[@"This Week"] = thisWeek;
												  if (nextWeek.count) comingEpisodes[@"Next Week"] = nextWeek;
												  if (future.count) comingEpisodes[@"Future"] = future;												  
												  
												  [self.tableView reloadData];
												  
												  [self finishDataLoad:nil];
											  }
										  }
										  failure:^(NSURLSessionDataTask *task, NSError *error) {
											  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving episodes", @"Error retrieving episodes")
																  message:error.localizedDescription 
															  buttonTitle:NSLocalizedString(@"OK", @"OK")];			
											  [self finishDataLoad:error];
										  }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return [[comingEpisodes allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [comingEpisodes allKeys][section];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString *title = [self tableView:tableView titleForHeaderInSection:section];
	
	SBSectionHeaderView *header = [[SBSectionHeaderView alloc] init];
	header.sectionLabel.text = title;
	return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 25;
}
	
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *keys = [comingEpisodes allKeys];
	NSString *sectionKey = keys[section];
	
	return [comingEpisodes[sectionKey] count];
}


- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ComingEpisodeCell *cell = (ComingEpisodeCell*)[tv dequeueReusableCellWithIdentifier:@"ComingEpisodeCell"];
	
	NSArray *keys = [comingEpisodes allKeys];
	NSString *sectionKey = keys[indexPath.section];
	SBComingEpisode *episode = comingEpisodes[sectionKey][indexPath.row];

	cell.showNameLabel.text = episode.show.showName;
	cell.networkLabel.text = episode.show.network;
	cell.episodeNameLabel.text = episode.name;
	cell.airDateLabel.text = [NSString stringWithFormat:@"%@ (%@)", [episode.airDate displayString], [SBShow showQualityAsString:episode.show.quality]];
	
	[cell.showImageView setImageWithURL:[self.apiClient posterURLForTVDBID:episode.show.tvdbID]
					   placeholderImage:[UIImage imageNamed:@"placeholder"]];

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


#pragma mark - Menu Actions
- (void)showMenu:(UIGestureRecognizer*)gesture {
	if (gesture.state == UIGestureRecognizerStateBegan) {
		[gesture.view becomeFirstResponder];
		
		menuIndexPath = [self.tableView indexPathForRowAtPoint:[gesture locationInView:self.tableView]];
		
		NSMutableArray *menuItems = [NSMutableArray arrayWithCapacity:2];
		
		UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Search", @"Search") action:@selector(searchForEpisode)];
		[menuItems addObject:item1];
		
		NSArray *keys = [comingEpisodes allKeys];
		NSString *sectionKey = keys[menuIndexPath.section];
		SBComingEpisode *episode = comingEpisodes[sectionKey][menuIndexPath.row];
		if ([comingEpisodes[@"Past"] containsObject:episode]) {
			[menuItems addObject:[[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Set Status", @"Set Status") action:@selector(setEpisodeStatus)]];
		}
		
		UIMenuController *menu = [UIMenuController sharedMenuController];
		menu.menuItems = menuItems;
		[menu setTargetRect:gesture.view.frame inView:gesture.view.superview];
		[menu setMenuVisible:YES animated:YES];
		
		[self.tableView selectRowAtIndexPath:menuIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
}

- (void)searchForEpisode {
	NSArray *keys = [comingEpisodes allKeys];
	NSString *sectionKey = keys[menuIndexPath.section];
	SBComingEpisode *episode = comingEpisodes[sectionKey][menuIndexPath.row];

	NSDictionary *params = @{@"tvdbid": episode.show.tvdbID, 
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
																				  type:TSMessageNotificationTypeMessage];
												  [self loadData];
											  }
											  else {
												  [TSMessage showNotificationWithTitle:JSON[@"message"]
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
	UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:[SBComingEpisode episodeStatusAsString:EpisodeStatusWanted] action:@selector(setEpisodeStatusToWanted)];
	UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:[SBComingEpisode episodeStatusAsString:EpisodeStatusSkipped] action:@selector(setEpisodeStatusToSkipped)];
	UIMenuItem *item3 = [[UIMenuItem alloc] initWithTitle:[SBComingEpisode episodeStatusAsString:EpisodeStatusArchived] action:@selector(setEpisodeStatusToArchived)];
	UIMenuItem *item4 = [[UIMenuItem alloc] initWithTitle:[SBComingEpisode episodeStatusAsString:EpisodeStatusIgnored] action:@selector(setEpisodeStatusToIgnored)];
	
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
	NSArray *keys = [comingEpisodes allKeys];
	NSString *sectionKey = keys[menuIndexPath.section];
	SBComingEpisode *episode = comingEpisodes[sectionKey][menuIndexPath.row];
	
	NSString *statusString = [[SBComingEpisode episodeStatusAsString:status] lowercaseString];
	
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
												  [self loadData];
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

@end
