//
//  SBShowsViewController.m
//  SickBeard
//
//  Created by Colin Humber on 8/26/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBShowsViewController.h"
#import "SBShowDetailsViewController.h"
#import "SBAddShowViewController.h"
#import "SBBacklogViewController.h"
#import "SickbeardAPIClient.h"
#import "SBShow.h"
#import "PRPAlertView.h"
#import "ShowCell.h"
#import "NSUserDefaults+SickBeard.h"
#import "NSDate+Utilities.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface SBShowsViewController () <SBAddShowDelegate>
@property (nonatomic, retain) NSMutableArray *tableData;

- (void)addShow;
@end



@implementation SBShowsViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"ShowDetailsSegue"]) {
		NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
		SBShow *show = (self.tableData)[selectedIndexPath.section][selectedIndexPath.row];

		SBShowDetailsViewController *detailsController = [segue destinationViewController];
		detailsController.show = show;
	}
	else if ([segue.identifier isEqualToString:@"AddShowSegue"]) {
		UINavigationController *navController = [segue destinationViewController];
		SBAddShowViewController *addShowController = (SBAddShowViewController*)navController.topViewController;
		addShowController.delegate = self;
	}
	else if ([segue.identifier isEqualToString:@"BacklogSegue"]) {
		UINavigationController *navController = segue.destinationViewController;
		SBBacklogViewController *backlogController = (SBBacklogViewController *)navController.topViewController;
		
		NSMutableArray *shows = [NSMutableArray array];
		
		for (NSArray *collatedShows in self.tableData) {
			[shows addObjectsFromArray:collatedShows];
		}
		
		backlogController.shows = shows;
	}
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];

	[self showEmptyView:NO animated:NO];
	self.emptyView.emptyLabel.text = NSLocalizedString(@"No shows found", @"No shows found");
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if ([NSUserDefaults standardUserDefaults].shouldUpdateShowList) {
		[NSUserDefaults standardUserDefaults].shouldUpdateShowList = NO;
		[self.tableData removeAllObjects];
		[self.tableView reloadData];
		
		[self loadData];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[TestFlight passCheckpoint:@"Viewed show list"];
	
	[super viewWillAppear:animated];
	
	if ([self tableView:self.tableView numberOfRowsInSection:0] > 0) {
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
	}
	else {
		if ([NSUserDefaults standardUserDefaults].serverHasBeenSetup) {
			if (!self.tableData) {
				[self.tableData removeAllObjects];
				[self loadData];
			}
		}
	}	
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	self.editing = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Loading
- (void)loadData {
	[super loadData];

	[SVProgressHUD showWithStatus:NSLocalizedString(@"Loading shows", @"Loading shows")];
	
	NSDictionary *params = @{@"sort": @"name"};
	
	[self.apiClient runCommand:SickBeardCommandShows 
									   parameters:params
										  success:^(NSURLSessionDataTask *task, id JSON) {
											  NSString *result = JSON[@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  NSMutableArray *shows = [[NSMutableArray alloc] init];
												  
												  NSDictionary *dataDict = JSON[@"data"];
												  
												  if (dataDict.allKeys.count > 0) {
													  for (NSString *key in [dataDict allKeys]) {
														  SBShow *show = [SBShow itemWithDictionary:dataDict[key]];
														  show.showName = key;
														  [shows addObject:show];
													  }
													  
													  NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"showName" ascending:YES];
													  [shows sortUsingDescriptors:@[sorter]];
													  
													  self.tableData = [SBGlobal partitionObjects:shows collationStringSelector:@selector(showName)];
												  }
												  else {
													  [self showEmptyView:YES animated:YES];
													  NSLog(@"No shows");
												  }
											  }
											  else {
												  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving shows", @"Error retrieving shows") 
																	  message:JSON[@"message"] 
																  buttonTitle:NSLocalizedString(@"OK", @"OK")];
											  }
										
											  [self finishDataLoad:nil];
											  [self.tableView reloadData];
										  }
										  failure:^(NSURLSessionDataTask *task, NSError *error) {

											  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving shows", @"Error retrieving shows")
																  message:error.localizedDescription 
															  buttonTitle:NSLocalizedString(@"OK", @"OK")];			
											  
											  [self finishDataLoad:error];
										  }];
}

#pragma mark - SBAddShowDelegate
- (void)didAddShow {
	[TestFlight passCheckpoint:@"Did add show"];
	[self dismissViewControllerAnimated:YES completion:^{
		[self loadData];
	}];
}

- (void)didCancelAddShow {
	[TestFlight passCheckpoint:@"Cancel add show"];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions
- (void)addShow {
	[self performSegueWithIdentifier:@"AddShowSegue" sender:nil];
	[TestFlight passCheckpoint:@"Adding show"];
}

- (IBAction)refresh:(id)sender {
	[self loadData];
	[TestFlight passCheckpoint:@"Refreshed shows list"];
}

#pragma mark - UITableViewDelegate
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	[self.parentViewController setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.tableData.count) {
		return [(self.tableData)[section] count];
	}
	
	return 0;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	if (self.tableData) {
		return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
	}
	
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}


- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ShowCell *cell = (ShowCell*)[tv dequeueReusableCellWithIdentifier:@"ShowCell"];
	
	SBShow *show = (self.tableData)[indexPath.section][indexPath.row];
	cell.showNameLabel.text = show.showName;	
	cell.networkLabel.text = show.network;
	cell.statusLabel.text = [SBShow showStatusAsString:show.status];
	
	
	if (show.status == ShowStatusEnded) {
		cell.statusLabel.textColor = RGBCOLOR(202, 50, 56);
		cell.nextEpisodeAirdateLabel.text = NSLocalizedString(@"Ended", @"Ended");
	}
	else {
		cell.nextEpisodeAirdateLabel.text = show.nextEpisodeDate != nil ? [show.nextEpisodeDate displayString] : NSLocalizedString(@"No airdate found", @"No airdate found");

		if (show.status == ShowStatusContinuing) {
			cell.statusLabel.textColor = RGBCOLOR(21, 93, 45);
		}
		else {
			cell.statusLabel.textColor = [UIColor grayColor];			
		}		
	}
	
	[cell.showImageView setImageWithURL:[self.apiClient posterURLForTVDBID:show.tvdbID]
					   placeholderImage:[UIImage imageNamed:@"placeholder"]];
//	[cell.showImageView setPathToNetworkImage:[[self.apiClient posterURLForTVDBID:show.tvdbID] absoluteString]];
	
	return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		SBShow *show = (self.tableData)[indexPath.section][indexPath.row];
		NSDictionary *params = @{@"tvdbid": show.tvdbID};

		[SVProgressHUD showWithStatus:NSLocalizedString(@"Deleting show", @"Deleting show")];
		
		[self.apiClient runCommand:SickBeardCommandShowDelete
										   parameters:params 
											  success:^(NSURLSessionDataTask *task, id JSON) {
												  NSString *result = JSON[@"result"];
												  
												  if ([result isEqualToString:RESULT_SUCCESS]) {
													  [(self.tableData)[indexPath.section] removeObjectAtIndex:indexPath.row];
													  [self.tableView deleteRowsAtIndexPaths:@[indexPath] 
																			withRowAnimation:UITableViewRowAnimationAutomatic];
												  }
												  else {
													  [PRPAlertView showWithTitle:NSLocalizedString(@"Could not delete show", @"Could not delete show") 
																		  message:JSON[@"message"] 
																	  buttonTitle:NSLocalizedString(@"OK", @"OK")];
												  }				
												  
												  [SVProgressHUD dismiss];
											  }
											  failure:^(NSURLSessionDataTask *task, NSError *error) {
												  [PRPAlertView showWithTitle:NSLocalizedString(@"Error deleting show", @"Error deleting show") 
																	  message:error.localizedDescription 
																  buttonTitle:NSLocalizedString(@"OK", @"OK")];			
												  [SVProgressHUD dismiss];
											  }];
	}
}


@end
