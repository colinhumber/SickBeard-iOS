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

#import <SDWebImage/UIImageView+WebCache.h>

typedef NS_ENUM(NSInteger, SBHistoryType) {
	SBHistoryTypeSnatched,
	SBHistoryTypeDownloaded
};

@interface SBHistoryViewController () <UIActionSheetDelegate> 
@property (nonatomic, strong) NSMutableArray *history;
@property (nonatomic, assign) SBHistoryType historyType;

- (IBAction)showHistoryActions:(id)sender;
- (IBAction)done:(id)sender;
@end


@implementation SBHistoryViewController

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];

	UISegmentedControl *historyControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Snatched", @"Snatched"), NSLocalizedString(@"Downloaded", @"Downloaded")]];
	
	historyControl.tintColor = RGBCOLOR(97, 77, 52);
	historyControl.selectedSegmentIndex = 0;
	
	[historyControl addTarget:self action:@selector(historyTypeChanged:) forControlEvents:UIControlEventValueChanged];
	
	UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:historyControl];
	NSMutableArray *items = [self.toolbarItems mutableCopy];
	[items insertObject:barItem atIndex:0];
	self.toolbarItems = @[flex, barItem, flex];
		
	self.emptyView.emptyLabel.text = NSLocalizedString(@"No history found", @"No history found");
	
	[self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if ([self tableView:self.tableView numberOfRowsInSection:0] > 0) {
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[SVProgressHUD dismiss];
}


- (BOOL)shouldAutorotate {
	return NO;
}

#pragma mark - Loading
- (void)loadData {
	[super loadData];
	
	[SVProgressHUD showWithStatus:NSLocalizedString(@"Loading history", @"Loading history")];
	
	NSString *filter = @"";
	if (self.historyType == SBHistoryTypeSnatched) {
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
												  self.history = [[NSMutableArray alloc] init];
												  
												  NSArray *data = JSON[@"data"];
												  
												  if (data.count > 0) {
													  for (NSDictionary *entry in data) {
														  SBHistory *item = [SBHistory itemWithDictionary:entry];
														  [self.history addObject:item];
													  }
													  
													  NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:NO];
													  [self.history sortUsingDescriptors:@[sorter]];
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
- (void)historyTypeChanged:(UISegmentedControl *)sender {
	self.historyType = sender.selectedSegmentIndex;
	[self loadData];
}

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
	[self loadData];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
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
	return self.history.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SBHistoryCell *cell = (SBHistoryCell*)[tv dequeueReusableCellWithIdentifier:@"SBHistoryCell"];
	
	SBHistory *entry = self.history[indexPath.row];
	cell.showNameLabel.text = entry.showName;	
	cell.createdDateLabel.text = [entry.createdDate displayDateTimeString];
	cell.seasonEpisodeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Season %d, episode %d", @"Season %d, episode %d"), entry.season, entry.episode];

	[cell.showImageView setImageWithURL:[self.apiClient posterURLForTVDBID:entry.tvdbID]
					   placeholderImage:[UIImage imageNamed:@"placeholder"]];
	
	return cell;
}

@end
