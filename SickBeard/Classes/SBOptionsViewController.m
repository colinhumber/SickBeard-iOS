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
#import "SBCellBackground.h"
#import "SBSectionHeaderView.h"
#import "SVProgressHUD.h"
#import "SBNotificationManager.h"

#define kInitialQualityIndex 0
#define kArchiveQualityIndex 1
#define kSeasonFolderIndex 2
#define kStatusIndex 3

#define kInitialQualitySegue @"InitialQualitySegue"
#define kArchiveQualitySegue @"ArchiveQualitySegue"
#define kStatusSegue @"StatusSegue"

@interface SBOptionsViewController()
@property (nonatomic, strong) NSIndexPath *parentFolderIndexPath;
@end


@implementation SBOptionsViewController

@synthesize show;
@synthesize delegate;
@synthesize parentFolderIndexPath;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:kInitialQualitySegue]) {
		SBQualityViewController *vc = segue.destinationViewController;
		vc.title = @"Initial Quality";
		vc.qualityType = QualityTypeInitial;
		vc.delegate = self;
		vc.currentQuality = initialQualities;
	}
	else if ([segue.identifier isEqualToString:kArchiveQualitySegue]) {
		SBQualityViewController *vc = segue.destinationViewController;
		vc.title = @"Archive Quality";
		vc.qualityType = QualityTypeArchive;
		vc.delegate = self;
		vc.currentQuality = archiveQualities;
	}
	else if ([segue.identifier isEqualToString:kStatusSegue]) {
		SBStatusViewController *vc = segue.destinationViewController;
		vc.delegate = self;
		vc.currentStatus = status;
	}
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
	self.enableRefreshHeader = NO;
	self.enableEmptyView = NO;

	[super viewDidLoad];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	defaultDirectories = defaults.defaultDirectories;
	initialQualities = defaults.initialQualities;
	archiveQualities = defaults.archiveQualities;
	status = defaults.status;
	useSeasonFolders = defaults.useSeasonFolders;
	parentFolder = defaults.defaultDirectory;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if ([self tableView:self.tableView numberOfRowsInSection:0] > 0) {
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

#pragma mark - Actions
- (IBAction)addShow {
	[[SBNotificationManager sharedManager] queueNotificationWithText:NSLocalizedString(@"Adding show", @"Adding show")
																type:SBNotificationTypeInfo];
	
	NSDictionary *params = @{@"tvdbid": show.tvdbID,
							@"location": parentFolder.path,
							@"lang": show.languageCode,
							@"season_folder": [NSString stringWithFormat:@"%d", useSeasonFolders],
							@"initial": [[SBGlobal qualitiesAsCodes:initialQualities] componentsJoinedByString:@"|"],
							@"archive": [[SBGlobal qualitiesAsCodes:archiveQualities] componentsJoinedByString:@"|"],
							@"status": [status lowercaseString]};
	
	[self.apiClient runCommand:SickBeardCommandShowAddNew
									   parameters:params 
										  success:^(NSURLSessionDataTask *task, id JSON) {
											  NSString *result = JSON[@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  [[SBNotificationManager sharedManager] queueNotificationWithText:NSLocalizedString(@"Show has been added", @"Show has been added")
																											  type:SBNotificationTypeSuccess];
												  
												  RunAfterDelay(1.5, ^{
													  [self.delegate didAddShow];
												  });
											  }
											  else {
												  [[SBNotificationManager sharedManager] queueNotificationWithText:JSON[@"message"]
																											  type:SBNotificationTypeError];
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
	[[SBNotificationManager sharedManager] queueNotificationWithText:NSLocalizedString(@"Saving defaults", @"Saving defaults")
																type:SBNotificationTypeInfo];
	
	NSDictionary *params = @{@"season_folder": [NSString stringWithFormat:@"%d", useSeasonFolders],
							@"initial": [[SBGlobal qualitiesAsCodes:initialQualities] componentsJoinedByString:@"|"],
							@"archive": [[SBGlobal qualitiesAsCodes:archiveQualities] componentsJoinedByString:@"|"],
							@"status": [status lowercaseString]};
	
	[self.apiClient runCommand:SickBeardCommandSetDefaults
									   parameters:params 
										  success:^(NSURLSessionDataTask *task, id JSON) {
											  NSString *result = JSON[@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {												  
												  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
												  defaults.useSeasonFolders = useSeasonFolders;
												  defaults.initialQualities = initialQualities;
												  defaults.archiveQualities = archiveQualities;
												  defaults.status = status;
												  
												  [defaults synchronize];
												  
												  if (![parentFolder isEqual:defaults.defaultDirectory]) {
													  [self.apiClient runCommand:SickBeardCommandAddRootDirectory
																						 parameters:@{@"location": parentFolder.path, @"default": @"1"} 
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
																									
																									[[SBNotificationManager sharedManager] queueNotificationWithText:NSLocalizedString(@"Defaults saved", @"Defaults saved")
																																								type:SBNotificationTypeSuccess];
																								}
																								else {
																									[[SBNotificationManager sharedManager] queueNotificationWithText:JSON[@"message"]
																																								type:SBNotificationTypeError];
																								}
																							}
																							failure:^(NSURLSessionDataTask *task, NSError *error) {
																								[PRPAlertView showWithTitle:NSLocalizedString(@"Error saving defaults", @"Error saving defaults")
																													message:error.localizedDescription 
																												buttonTitle:NSLocalizedString(@"OK", @"OK")];
																							}];
												  }
												  else {
													  [[SBNotificationManager sharedManager] queueNotificationWithText:NSLocalizedString(@"Defaults saved", @"Defaults saved")
																												  type:SBNotificationTypeSuccess];
												  }
											  }
											  else {
												  [[SBNotificationManager sharedManager] queueNotificationWithText:JSON[@"message"]
																											  type:SBNotificationTypeError];
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
	status = [[stat capitalizedString] copy];
	[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kStatusIndex inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)qualityViewController:(SBQualityViewController *)controller didSelectQualities:(NSMutableArray *)qualities {
	[TestFlight passCheckpoint:@"Changed quality options"];
	
	if (controller.qualityType == QualityTypeInitial) {
		initialQualities = qualities;
		[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kInitialQualityIndex inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
	}
	else if (controller.qualityType == QualityTypeArchive) {
		archiveQualities = qualities;
		[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kArchiveQualityIndex inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
	}
}

- (IBAction)useSeasonFoldersChanged:(id)sender {
	UISwitch *switchy = sender;
	useSeasonFolders = switchy.on;
}

#pragma mark - UITableViewDataSource
- (int)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	int numberOfRows = 0;
	
	switch (section) {
		case 0:
			numberOfRows = defaultDirectories.count;
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
		SBRootDirectory *directory = defaultDirectories[indexPath.row];
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
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", initialQualities.count];
				break;
			
			case 1:
				cell = [tableView dequeueReusableCellWithIdentifier:@"TextOptionCell"];
				cell.textLabel.text = NSLocalizedString(@"Archive Quality", @"Archive Quality");
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", archiveQualities.count];
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
				cell.detailTextLabel.text = status;
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
			parentFolder = defaultDirectories[indexPath.row];
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
