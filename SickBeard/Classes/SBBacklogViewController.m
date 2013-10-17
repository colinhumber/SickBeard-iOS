//
//  SBBacklogViewController.m
//  SickBeard
//
//  Created by Colin Humber on 11/8/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBBacklogViewController.h"
#import "SBEpisodeDetailsViewController.h"
#import "ShowCell.h"
#import "SBShow.h"
#import "SBEpisode.h"
#import "EpisodeCell.h"
#import "SickbeardAPIClient.h"
#import "PRPAlertView.h"
#import "NSUserDefaults+SickBeard.h"
#import "NSDate+Utilities.h"
#import "SVProgressHUD.h"
#import "SBSectionHeaderView.h"

#import "SBServer.h"
#import "SBCommandBuilder.h"
#import <AFNetworking/AFHTTPRequestOperation.h>

@interface SBBacklogViewController () <SBSectionHeaderViewDelegate>
@property (nonatomic, strong) NSMutableArray *sectionHeaders;
@property (nonatomic, strong) OrderedDictionary *backlog;
@end

@implementation SBBacklogViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"EpisodeDetailsSegue"]) {
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		SBEpisodeDetailsViewController *vc = segue.destinationViewController;
		
		NSArray *seasonKeys = [_backlog allKeys];
		SBEpisode *episode = _backlog[seasonKeys[indexPath.section]][indexPath.row];
		vc.episode = episode;
	}
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];

	self.emptyView.emptyLabel.text = NSLocalizedString(@"No episodes backlogged", @"No episodes backlogged");
	
	_backlog = [[OrderedDictionary alloc] init];
	_sectionHeaders = [[NSMutableArray alloc] init];

	[self loadData];
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[SVProgressHUD dismiss];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Loading
- (void)loadData {
	[super loadData];
	
	[SVProgressHUD showWithStatus:NSLocalizedString(@"Loading backlog", @"Loading backlog")];

	SBServer *currentServer = [NSUserDefaults standardUserDefaults].server;
	NSMutableArray *operations = [NSMutableArray arrayWithCapacity:self.shows.count];
	
	for (SBShow *show in self.shows) {
		NSDictionary *params = @{ @"tvdbid" : show.tvdbID };
		
		NSString *urlPath = [SBCommandBuilder URLForCommand:SickBeardCommandSeasons
													 server:currentServer
													 params:params];

		AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlPath]]];
		operation.responseSerializer = [AFJSONResponseSerializer serializer];
		[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
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
				
				NSMutableArray *episodes = [NSMutableArray array];
				
				for (NSString *seasonNumber in seasonNumbers) {
					NSDictionary *seasonDict = dataDict[seasonNumber];
					
					for (NSString *episodeNumber in [seasonDict allKeys]) {
						SBEpisode *episode = [SBEpisode itemWithDictionary:seasonDict[episodeNumber]];
						
						if (episode.status == EpisodeStatusWanted) {
							episode.show = show;
							episode.season = [seasonNumber intValue];
							episode.number = [episodeNumber intValue];
							[episodes addObject:episode];
						}
					}
				}
				
				if (episodes.count) {
					[episodes sortUsingComparator:^NSComparisonResult(SBEpisode *ep1, SBEpisode *ep2) {
						NSComparisonResult result = [ep1.airDate compare:ep2.airDate];
						
						if (result == NSOrderedAscending) {
							return NSOrderedDescending;
						}
						else if (result == NSOrderedDescending) {
							return NSOrderedAscending;
						}
						else {
							return NSOrderedSame;
						}
					}];
					
					_backlog[show.showName] = episodes;
					[_sectionHeaders addObject:[NSNull null]];
				}
			}
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"FAILURE!!! %@", operation);
		}];
//		AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlPath]]
//																							success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//																								NSString *result = [JSON objectForKey:@"result"];
//																								
//																								if ([result isEqualToString:RESULT_SUCCESS]) {
//																									NSDictionary *dataDict = [JSON objectForKey:@"data"];
//																									
//																									NSArray *seasonNumbers = [[dataDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *s1, NSString *s2) {
//																										if ([s1 intValue] < [s2 intValue]) {
//																											return NSOrderedDescending;
//																										}
//																										else if ([s1 intValue] > [s2 intValue]) {
//																											return NSOrderedAscending;
//																										}
//																										else {
//																											return NSOrderedSame;
//																										}
//																									}];
//
//																									NSMutableArray *episodes = [NSMutableArray array];
//																									
//																									for (NSString *seasonNumber in seasonNumbers) {
//																										NSDictionary *seasonDict = [dataDict objectForKey:seasonNumber];
//																										
//																										for (NSString *episodeNumber in [seasonDict allKeys]) {
//																											SBEpisode *episode = [SBEpisode itemWithDictionary:[seasonDict objectForKey:episodeNumber]];
//																											
//																											if (episode.status == EpisodeStatusWanted) {
//																												episode.show = show;
//																												episode.season = [seasonNumber intValue];
//																												episode.number = [episodeNumber intValue];
//																												[episodes addObject:episode];
//																											}
//																										}
//																									}
//																									
//																									if (episodes.count) {
//																										[episodes sortUsingComparator:^NSComparisonResult(SBEpisode *ep1, SBEpisode *ep2) {
//																											NSComparisonResult result = [ep1.airDate compare:ep2.airDate];
//																											
//																											if (result == NSOrderedAscending) {
//																												return NSOrderedDescending;
//																											}
//																											else if (result == NSOrderedDescending) {
//																												return NSOrderedAscending;
//																											}
//																											else {
//																												return NSOrderedSame;
//																											}
//																										}];
//																										
//																										[_backlog setObject:episodes forKey:show.showName];
//																										[_sectionHeaders addObject:[NSNull null]];
//																									}
//																								}
//																							}
//																							failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//																								NSLog(@"FAILURE!!! %@", request);
//																							}];
		
		[operations addObject:operation];
	}
	
	[AFHTTPRequestOperation batchOfRequestOperations:operations
									   progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
										   
									   } completionBlock:^(NSArray *operations) {
										   [SVProgressHUD dismiss];
										   [self.tableView reloadData];
									   }];
//	[self.apiClient enqueueBatchOfHTTPRequestOperations:operations
//								  progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
//								  }
//								completionBlock:^(NSArray *operations) {
//									[SVProgressHUD dismiss];
//									[self.tableView reloadData];
//								}];
}

#pragma mark - Actions
- (IBAction)done:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)refresh:(id)sender {
	[TestFlight passCheckpoint:@"Refreshed backlog"];
	
	[self loadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return [[_backlog allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSArray *keys = [_backlog allKeys];
	return keys[section];
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
	return 50;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *keys = [_backlog allKeys];
	NSString *sectionKey = keys[section];
	
	SBSectionHeaderView *headerView = (SBSectionHeaderView *)[self tableView:tableView viewForHeaderInSection:section];
	
	return headerView.state == SBSectionHeaderStateOpen ? [_backlog[sectionKey] count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	EpisodeCell *cell = (EpisodeCell *)[tv dequeueReusableCellWithIdentifier:@"EpisodeCell"];
	
	NSArray *keys = [_backlog allKeys];
	NSString *sectionKey = keys[indexPath.section];
	NSArray *episodes = _backlog[sectionKey];
	
	SBEpisode *episode = episodes[indexPath.row];
	
	cell.episodeNameLabel.text = episode.name;
	cell.airdateLabel.text = episode.airDate ? [episode.airDate displayString] : NSLocalizedString(@"Unknown Air Date", @"Unknown Air Date");
	cell.badgeView.textLabel.text = [SBEpisode episodeStatusAsString:episode.status];
	cell.badgeView.badgeColor = RGBCOLOR(231, 147, 0);
	
//	if (indexPath.row == episodes.count - 1) {
//		cell.lastCell = YES;
//	}
//	else {
//		cell.lastCell = NO;
//	}
	
	return cell;
}

#pragma mark - SBSectionHeaderViewDelegate
- (void)sectionHeaderView:(SBSectionHeaderView*)sectionHeaderView sectionOpened:(NSInteger)sectionOpened {
	sectionHeaderView.state = SBSectionHeaderStateOpen;
    /*
     Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
     */
	NSArray *keys = [_backlog allKeys];
	NSString *sectionKey = keys[sectionOpened];
	
    NSInteger countOfRowsToInsert = [_backlog[sectionKey] count];
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
