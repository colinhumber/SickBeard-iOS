//
//  SBOptionsViewController.m
//  SickBeard
//
//  Created by Colin Humber on 9/8/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBOptionsViewController.h"
#import "SBShow.h"
#import "SBRootDirectory.h"
#import "SickbeardAPIClient.h"
#import "PRPAlertView.h"
#import "SBSectionHeaderView.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "SBNotificationManager.h"

#define kInitialQualityIndex 0
#define kArchiveQualityIndex 1
#define kSeasonFolderIndex 2
#define kStatusIndex 3

#define kInitialQualitySegue @"InitialQualitySegue"
#define kArchiveQualitySegue @"ArchiveQualitySegue"
#define kStatusSegue @"StatusSegue"

@interface SBOptionsViewController()
@property (nonatomic, strong) NSMutableArray *initialQualities;
@property (nonatomic, strong) NSMutableArray *archiveQualities;
@property (nonatomic, strong) NSMutableArray *defaultDirectories;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) SBRootDirectory *parentFolder;
@property (nonatomic, assign) BOOL useSeasonFolders;
@property (nonatomic, strong) NSIndexPath *parentFolderIndexPath;
@end


@implementation SBOptionsViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:kInitialQualitySegue]) {
		SBQualityViewController *vc = segue.destinationViewController;
		vc.title = @"Initial Quality";
		vc.qualityType = QualityTypeInitial;
		vc.delegate = self;
		vc.currentQuality = self.initialQualities;
	}
	else if ([segue.identifier isEqualToString:kArchiveQualitySegue]) {
		SBQualityViewController *vc = segue.destinationViewController;
		vc.title = @"Archive Quality";
		vc.qualityType = QualityTypeArchive;
		vc.delegate = self;
		vc.currentQuality = self.archiveQualities;
	}
	else if ([segue.identifier isEqualToString:kStatusSegue]) {
		SBStatusViewController *vc = segue.destinationViewController;
		vc.delegate = self;
		vc.currentStatus = self.status;
	}
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
	self.enableRefreshHeader = NO;
	self.enableEmptyView = NO;

	[super viewDidLoad];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	self.defaultDirectories = defaults.defaultDirectories;
	self.initialQualities = defaults.initialQualities;
	self.archiveQualities = defaults.archiveQualities;
	self.status = defaults.status;
	self.useSeasonFolders = defaults.useSeasonFolders;
	self.parentFolder = defaults.defaultDirectory;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if ([self tableView:self.tableView numberOfRowsInSection:0] > 0) {
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
	}
}

- (BOOL)shouldAutorotate {
	return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

#pragma mark - Actions
- (IBAction)addShow {
	[TSMessage showNotificationWithTitle:NSLocalizedString(@"Adding show", @"Adding show")
									type:TSMessageNotificationTypeMessage];
	
	NSDictionary *params = @{@"tvdbid": self.show.tvdbID,
							@"location": self.parentFolder.path,
							@"lang": self.show.languageCode,
							@"season_folder": [NSString stringWithFormat:@"%d", self.useSeasonFolders],
							@"initial": [[SBGlobal qualitiesAsCodes:self.initialQualities] componentsJoinedByString:@"|"],
							@"archive": [[SBGlobal qualitiesAsCodes:self.archiveQualities] componentsJoinedByString:@"|"],
							@"status": [self.status lowercaseString]};
	
	[self.apiClient runCommand:SickBeardCommandShowAddNew
									   parameters:params 
										  success:^(NSURLSessionDataTask *task, id JSON) {
											  NSString *result = JSON[@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  [TSMessage showNotificationWithTitle:NSLocalizedString(@"Show has been added", @"Show has been added")
																				  type:TSMessageNotificationTypeSuccess];
												  
												  RunAfterDelay(1.5, ^{
													  [self.delegate didAddShow];
												  });
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

- (void)saveDefaults {
	[TestFlight passCheckpoint:@"Saved server defaults"];
	[TSMessage showNotificationWithTitle:NSLocalizedString(@"Saving defaults", @"Saving defaults")
																type:TSMessageNotificationTypeMessage];
	
	NSDictionary *params = @{@"season_folder": [NSString stringWithFormat:@"%d", self.useSeasonFolders],
							@"initial": [[SBGlobal qualitiesAsCodes:self.initialQualities] componentsJoinedByString:@"|"],
							@"archive": [[SBGlobal qualitiesAsCodes:self.archiveQualities] componentsJoinedByString:@"|"],
							@"status": [self.status lowercaseString]};
	
	[self.apiClient runCommand:SickBeardCommandSetDefaults
									   parameters:params 
										  success:^(NSURLSessionDataTask *task, id JSON) {
											  NSString *result = JSON[@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {												  
												  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
												  defaults.useSeasonFolders = self.useSeasonFolders;
												  defaults.initialQualities = self.initialQualities;
												  defaults.archiveQualities = self.archiveQualities;
												  defaults.status = self.status;
												  
												  [defaults synchronize];
												  
												  if (![self.parentFolder isEqual:defaults.defaultDirectory]) {
													  [self.apiClient runCommand:SickBeardCommandAddRootDirectory
																						 parameters:@{@"location": self.parentFolder.path, @"default": @"1"}
																							success:^(NSURLSessionDataTask *task, id JSON) {
																								NSString *result = JSON[@"result"];
																								
																								if ([result isEqualToString:RESULT_SUCCESS]) {
																									NSArray *data = JSON[@"data"];
																									
																									NSMutableArray *directories = [NSMutableArray arrayWithCapacity:data.count];
																									for (NSDictionary *dir in data) {
																										SBRootDirectory *directory = [SBRootDirectory itemWithDictionary:dir];
																										if (directory.isValid) {
																											[directories addObject:directory];
																										}
																									}
																									NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
																									defaults.defaultDirectories = directories;
																									
																									[defaults synchronize];
																									
																									[TSMessage showNotificationWithTitle:NSLocalizedString(@"Defaults saved", @"Defaults saved")
																																								type:TSMessageNotificationTypeSuccess];
																								}
																								else {
																									[TSMessage showNotificationWithTitle:JSON[@"message"]
																																								type:TSMessageNotificationTypeError];
																								}
																							}
																							failure:^(NSURLSessionDataTask *task, NSError *error) {
																								[PRPAlertView showWithTitle:NSLocalizedString(@"Error saving defaults", @"Error saving defaults")
																													message:error.localizedDescription 
																												buttonTitle:NSLocalizedString(@"OK", @"OK")];
																							}];
												  }
												  else {
													  [TSMessage showNotificationWithTitle:NSLocalizedString(@"Defaults saved", @"Defaults saved")
																												  type:TSMessageNotificationTypeSuccess];
												  }
											  }
											  else {
												  [TSMessage showNotificationWithTitle:JSON[@"message"]
																											  type:TSMessageNotificationTypeError];
											  }
										  }
										  failure:^(NSURLSessionDataTask *task, NSError *error) {
											  [PRPAlertView showWithTitle:NSLocalizedString(@"Error saving defaults", @"Error saving defaults") 
																  message:error.localizedDescription
															  buttonTitle:NSLocalizedString(@"OK", @"OK")];											  
											  
										  }];
}

#pragma mark - Quality, Status, and Season Folders
- (void)statusViewController:(SBStatusViewController *)controller didSelectStatus:(NSString *)stat {
	self.status = [[stat capitalizedString] copy];
	[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kStatusIndex inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)qualityViewController:(SBQualityViewController *)controller didSelectQualities:(NSMutableArray *)qualities {
	[TestFlight passCheckpoint:@"Changed quality options"];
	
	if (controller.qualityType == QualityTypeInitial) {
		self.initialQualities = qualities;
		[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kInitialQualityIndex inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
	}
	else if (controller.qualityType == QualityTypeArchive) {
		self.archiveQualities = qualities;
		[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kArchiveQualityIndex inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
	}
}

- (IBAction)useSeasonFoldersChanged:(id)sender {
	UISwitch *switchy = sender;
	self.useSeasonFolders = switchy.on;
}

#pragma mark - UITableViewDataSource
- (int)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	int numberOfRows = 0;
	
	switch (section) {
		case 0:
			numberOfRows = self.defaultDirectories.count;
			break;
			
		case 1:
			numberOfRows = 4;
			break;
			
		case 2:
			numberOfRows = 1;
			break;
		
		default:
			break;
	}
	
	return numberOfRows;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *title = nil;
	
	switch (section) {
		case 0:
			title = NSLocalizedString(@"Parent Folder", @"Parent folder");
			break;
			
		case 1:
			title = NSLocalizedString(@"Customize Options", @"Customize Options");
			break;
			
		default:
			break;
	}
	
	return title;
}

- (UIView*)tableView:(UITableView *)tv viewForHeaderInSection:(NSInteger)section {
	NSString *title = [self tableView:tv titleForHeaderInSection:section];
	
	if (!title) {
		return nil;
	}
	
	SBSectionHeaderView *header = [[SBSectionHeaderView alloc] init];
	header.sectionLabel.text = title;
	return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 2) {
		return 0;
	}
	
	return 25;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	if (indexPath.section == 0) {
		SBRootDirectory *directory = self.defaultDirectories[indexPath.row];
		cell = [tableView dequeueReusableCellWithIdentifier:@"FolderCell"];
		cell.textLabel.text = directory.path;
		
		if (directory.isDefault) {
			self.parentFolderIndexPath = indexPath;
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
		else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	}
	else if (indexPath.section == 1) {
		switch (indexPath.row) {
			case 0:
				cell = [tableView dequeueReusableCellWithIdentifier:@"TextOptionCell"];
				cell.textLabel.text = NSLocalizedString(@"Initial Quality", @"Initial Quality");
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.initialQualities.count];
				break;
			
			case 1:
				cell = [tableView dequeueReusableCellWithIdentifier:@"TextOptionCell"];
				cell.textLabel.text = NSLocalizedString(@"Archive Quality", @"Archive Quality");
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.archiveQualities.count];
				break;
				
			case 2:
			{
				cell = [tableView dequeueReusableCellWithIdentifier:@"SeasonFolderCell"];
				UISwitch *switchy = (UISwitch*)[cell.contentView viewWithTag:999];
				switchy.on = [NSUserDefaults standardUserDefaults].useSeasonFolders;
				break;
			}
				
			case 3:
				cell = [tableView dequeueReusableCellWithIdentifier:@"TextOptionCell"];
				cell.textLabel.text = NSLocalizedString(@"Status", @"Status");
				cell.detailTextLabel.text = self.status;
				break;
			default:
				break;
		}
	}
	else {
		cell = [tableView dequeueReusableCellWithIdentifier:@"SaveDefaultsCell"];
	}
	
	return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	if (indexPath.section == 0) {
		if ([indexPath compare:self.parentFolderIndexPath] == NSOrderedSame) {
			return;
		}		
		
		UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
		if (newCell.accessoryType == UITableViewCellAccessoryNone) {
			newCell.accessoryType = UITableViewCellAccessoryCheckmark;
			self.parentFolder = self.defaultDirectories[indexPath.row];
		}
		
		UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.parentFolderIndexPath];
		if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
			oldCell.accessoryType = UITableViewCellAccessoryNone;
		}
		
		self.parentFolderIndexPath = indexPath;
	}
	else if (indexPath.section == 1) {
		switch (indexPath.row) {
			case kInitialQualityIndex:
				[self performSegueWithIdentifier:kInitialQualitySegue sender:nil];
				break;

			case kArchiveQualityIndex:
				[self performSegueWithIdentifier:kArchiveQualitySegue sender:nil];
				break;

			case kStatusIndex:
				[self performSegueWithIdentifier:kStatusSegue sender:nil];
				break;

			default:
				break;
		}
	}
	else if (indexPath.section == 2 && indexPath.row == 0) {
		[self saveDefaults];
	}
}

@end
