//
//  SBHistoryViewController.m
//  SickBeard
//
//  Created by Colin Humber on 11/8/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBHistoryViewController.h"
#import "SickbeardAPIClient.h"
#import "SBHistory.h"
#import "PRPAlertView.h"
#import "NSUserDefaults+SickBeard.h"
#import "SBHistoryCell.h"
#import "NSDate+Utilities.h"
#import "SVSegmentedControl.h"
#import "SVProgressHUD.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation SBHistoryViewController

@synthesize tableView;

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
//	self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.navigationController.toolbar.frame.size.height, 0);
//	self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
//	
	[super viewDidLoad];

	SVSegmentedControl *historyControl = [[SVSegmentedControl alloc] initWithSectionTitles:
										  @[NSLocalizedString(@"Snatched", @"Snatched"), NSLocalizedString(@"Downloaded", @"Downloaded")]];

	historyControl.thumb.tintColor = RGBCOLOR(127, 92, 59);
	historyControl.changeHandler = ^(NSUInteger newIndex) {
		[TestFlight passCheckpoint:@"Changed history type"];
		
		historyType = newIndex;
		[self loadData];
	};
	
	UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:historyControl];
	NSMutableArray *items = [self.toolbarItems mutableCopy];
	[items insertObject:barItem atIndex:2];
	self.toolbarItems = items;
		
	self.emptyView.emptyLabel.text = NSLocalizedString(@"No history found", @"No history found");
	
	[self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if ([self tableView:self.tableView numberOfRowsInSection:0] > 0) {
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
	}
//	else {
//		if ([NSUserDefaults standardUserDefaults].serverHasBeenSetup) {
//			if (!history) {
//				[history removeAllObjects];
//				[self loadData];
//			}
//		}		
//	}
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
	
	[SVProgressHUD showWithStatus:NSLocalizedString(@"Loading history", @"Loading history")];
	
	NSString *filter = @"";
	if (historyType == SBHistoryTypeSnatched) {
		filter = @"snatched";
	}
	else {
		filter = @"downloaded";
	}

	NSDictionary *params = @{@"type": filter};
	
	[self.apiClient runCommand:SickBeardCommandHistory
									   parameters:params
										  success:^(NSURLSessionDataTask *task, id JSON) {
											  NSString *result = JSON[@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  history = [[NSMutableArray alloc] init];
												  
												  NSArray *data = JSON[@"data"];
												  
												  if (data.count > 0) {
													  for (NSDictionary *entry in data) {
														  SBHistory *item = [SBHistory itemWithDictionary:entry];
														  [history addObject:item];
													  }
													  
													  NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:NO];
													  [history sortUsingDescriptors:@[sorter]];
												  }
												  else {
													  [self showEmptyView:YES animated:YES];
													  NSLog(@"No history");
												  }
											  }
											  else {
												  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving history", @"Error retrieving history")
																	  message:JSON[@"message"] 
																  buttonTitle:NSLocalizedString(@"OK", @"OK")];
											  }
											  
											  [self finishDataLoad:nil];
											  [self.tableView reloadData];
										  }
										  failure:^(NSURLSessionDataTask *task, NSError *error) {
											  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving history", @"Error retrieving history") 
																  message:error.localizedDescription 
															  buttonTitle:NSLocalizedString(@"OK", @"OK")];			
											  
											  [self finishDataLoad:error];
										  }];
}

#pragma mark - Actions
- (IBAction)showHistoryActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" 
															 delegate:self 
													cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") 
											   destructiveButtonTitle:NSLocalizedString(@"Clear History", @"Clear History") 
													otherButtonTitles:NSLocalizedString(@"Trim History", @"Trim History"), nil];
	[actionSheet showFromToolbar:self.navigationController.toolbar];
}

- (IBAction)done:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)refresh:(id)sender {
	[TestFlight passCheckpoint:@"Refreshed history"];
	
	[self loadData];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		[TestFlight passCheckpoint:@"Cleared history"];
		
		[SVProgressHUD showWithStatus:NSLocalizedString(@"Clearing history", @"Clearing history")];
		[self.apiClient runCommand:SickBeardCommandHistoryClear
										   parameters:nil 
											  success:^(NSURLSessionDataTask *task, id JSON) {
												  [SVProgressHUD dismiss];
												  [self loadData];
											  } 
											  failure:^(NSURLSessionDataTask *task, NSError *error) {
												  [PRPAlertView showWithTitle:NSLocalizedString(@"Error clearing history", @"Error clearing history")
																	  message:error.localizedDescription 
																  buttonTitle:NSLocalizedString(@"OK", @"OK")];
											  }];
	}
	else if (buttonIndex == 1) {
		[TestFlight passCheckpoint:@"Trimmed history"];
		
		[SVProgressHUD showWithStatus:NSLocalizedString(@"Trimming history", @"Trimming history")];
		[self.apiClient runCommand:SickBeardCommandHistoryTrim
										   parameters:nil 
											  success:^(NSURLSessionDataTask *task, id JSON) {
												  [SVProgressHUD dismiss];
												  [self loadData];
											  } 
											  failure:^(NSURLSessionDataTask *task, NSError *error) {
												  [PRPAlertView showWithTitle:NSLocalizedString(@"Error trimming history", @"Error trimming history") 
																	  message:error.localizedDescription 
																  buttonTitle:NSLocalizedString(@"OK", @"OK")];
											  }];
	}
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return history.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SBHistoryCell *cell = (SBHistoryCell*)[tv dequeueReusableCellWithIdentifier:@"SBHistoryCell"];
	
	SBHistory *entry = history[indexPath.row];
	cell.showNameLabel.text = entry.showName;	
	cell.createdDateLabel.text = [entry.createdDate displayDateTimeString];
	cell.seasonEpisodeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Season %d, episode %d", @"Season %d, episode %d"), entry.season, entry.episode];

//	[cell.showImageView setPathToNetworkImage:[[self.apiClient posterURLForTVDBID:entry.tvdbID] absoluteString]];
	[cell.showImageView setImageWithURL:[self.apiClient posterURLForTVDBID:entry.tvdbID]
					   placeholderImage:[UIImage imageNamed:@"placeholder"]];
	
	return cell;
}

@end
