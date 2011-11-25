//
//  SBOptionsViewController.m
//  SickBeard
//
//  Created by Colin Humber on 9/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBOptionsViewController.h"
#import "SBShow.h"
#import "SBRootDirectory.h"
#import "ATMHud.h"
#import "SickbeardAPIClient.h"
#import "PRPAlertView.h"

#define kInitialQualityIndex 0
#define kArchiveQualityIndex 1
#define kSeasonFolderIndex 2
#define kStatusIndex 3

#define kInitialQualitySegue @"InitialQualitySegue"
#define kArchiveQualitySegue @"ArchiveQualitySegue"
#define kStatusSegue @"StatusSegue"

@interface SBOptionsViewController()
@property (nonatomic, strong) ATMHud *hud;
@property (nonatomic, strong) NSIndexPath *parentFolderIndexPath;
@end


@implementation SBOptionsViewController

@synthesize show;
//@synthesize locationTextField;
//@synthesize initialQualityLabel;
//@synthesize archiveQualityLabel;
//@synthesize statusLabel;
//@synthesize seasonFolderSwitch;
@synthesize hud;
@synthesize parentFolderIndexPath;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//	if ([locationTextField isFirstResponder]){
//		[locationTextField resignFirstResponder];
//	}
	
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
	self.hud = [[ATMHud alloc] init];
	[self.view addSubview:self.hud.view];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	defaultDirectories = defaults.defaultDirectories;
	initialQualities = defaults.initialQualities;
	archiveQualities = defaults.archiveQualities;
	status = defaults.status;
	useSeasonFolders = defaults.useSeasonFolders;
	
//	self.initialQualityLabel.text = [NSString stringWithFormat:@"%d", initialQualities.count];
//	self.archiveQualityLabel.text = [NSString stringWithFormat:@"%d", archiveQualities.count];
//	self.statusLabel.text = status;
//	self.seasonFolderSwitch.on = defaults.useSeasonFolders;
	
    [super viewDidLoad];
}

- (void)viewDidUnload {
//	self.initialQualityLabel = nil;
//	self.archiveQualityLabel = nil;
//	self.statusLabel = nil;
//	self.seasonFolderSwitch = nil;
	
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

#pragma mark - Actions
- (IBAction)addShow {
	[self.hud setCaption:@"Adding show..."];
	[self.hud setActivity:YES];
	[self.hud show];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							show.tvdbID, @"tvdbid",
							parentFolder.path, @"location",
							show.languageCode, @"lang",
							[NSString stringWithFormat:@"%d", useSeasonFolders], @"season_folder",
							[[SBGlobal qualitiesAsCodes:initialQualities] componentsJoinedByString:@"|"], @"initial",
							[[SBGlobal qualitiesAsCodes:archiveQualities] componentsJoinedByString:@"|"], @"archive",
							[status lowercaseString], @"status",
							nil];
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandShowAddNew 
									   parameters:params 
										  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  [self.hud setCaption:@"Show has been added"];
												  [self.hud setActivity:NO];
												  [self.hud setImage:[UIImage imageNamed:@"19-check"]];
												  [self.hud update];
												  
												  [self.hud hideAfter:2];
												  
												  RunAfterDelay(3, ^{
													  [self dismissViewControllerAnimated:YES completion:nil];
												  });
											  }
											  else {
												  [self.hud setCaption:[JSON objectForKey:@"message"]];
												  [self.hud setActivity:NO];
												  [self.hud setImage:[UIImage imageNamed:@"11-x"]];
												  [self.hud update];
												  
												  [self.hud hideAfter:2];
											  }
										  }
										  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
											  [PRPAlertView showWithTitle:@"Error searching for show" 
																  message:[NSString stringWithFormat:@"Could not perform search \n%@", error.localizedDescription] 
															  buttonTitle:@"OK"];											  
											  
										  }];
}

- (void)saveDefaults {
	[self.hud setCaption:@"Saving defaults..."];
	[self.hud setActivity:YES];
	[self.hud show];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", useSeasonFolders], @"season_folder",
							[[SBGlobal qualitiesAsCodes:initialQualities] componentsJoinedByString:@"|"], @"initial",
							[[SBGlobal qualitiesAsCodes:archiveQualities] componentsJoinedByString:@"|"], @"archive",
							[status lowercaseString], @"status",
							nil];
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandSetDefaults 
									   parameters:params 
										  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {												  
												  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
												  defaults.useSeasonFolders = useSeasonFolders;
												  defaults.initialQualities = initialQualities;
												  defaults.archiveQualities = archiveQualities;
												  defaults.status = status;
												  
												  [defaults synchronize];
												  
												  if (![parentFolder isEqual:defaults.defaultDirectory]) {
													  [[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandAddRootDirectory
																						 parameters:[NSDictionary dictionaryWithObjectsAndKeys:parentFolder.path, @"location", @"1", @"default", nil] 
																							success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
																								NSString *result = [JSON objectForKey:@"result"];
																								
																								if ([result isEqualToString:RESULT_SUCCESS]) {
																									NSArray *data = [JSON objectForKey:@"data"];
																									
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
																									
																									[self.hud setCaption:@"Defaults saved"];
																									[self.hud setActivity:NO];
																									[self.hud setImage:[UIImage imageNamed:@"19-check"]];
																									[self.hud update];
																									[self.hud hideAfter:2];
																								}
																								else {
																									[self.hud setCaption:[JSON objectForKey:@"message"]];
																									[self.hud setActivity:NO];
																									[self.hud setImage:[UIImage imageNamed:@"11-x"]];
																									[self.hud update];
																									
																									[self.hud hideAfter:2];
																								}
																							}
																							failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
																								[PRPAlertView showWithTitle:@"Error saving defaults" 
																													message:[NSString stringWithFormat:@"Could not save defaults. \n%@", error.localizedDescription] 
																												buttonTitle:@"OK"];
																							}];
												  }
												  else {
													  [self.hud setCaption:@"Defaults saved"];
													  [self.hud setActivity:NO];
													  [self.hud setImage:[UIImage imageNamed:@"19-check"]];
													  [self.hud update];
												  }
											  }
											  else {
												  [self.hud setCaption:[JSON objectForKey:@"message"]];
												  [self.hud setActivity:NO];
												  [self.hud setImage:[UIImage imageNamed:@"11-x"]];
												  [self.hud update];
												  
												  [self.hud hideAfter:2];
											  }
										  }
										  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
											  [PRPAlertView showWithTitle:@"Error saving defaults" 
																  message:[NSString stringWithFormat:@"Could not save defaults. \n%@", error.localizedDescription] 
															  buttonTitle:@"OK"];											  
											  
										  }];
}

#pragma mark - Quality, Status, and Season Folders
- (void)statusViewController:(SBStatusViewController *)controller didSelectStatus:(NSString *)stat {
	status = [stat copy];
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kStatusIndex inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
	//self.statusLabel.text = status;
}

- (void)qualityViewController:(SBQualityViewController *)controller didSelectQualities:(NSMutableArray *)qualities {
	if (controller.qualityType == QualityTypeInitial) {
		initialQualities = qualities;
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kInitialQualityIndex inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
//		self.initialQualityLabel.text = [NSString stringWithFormat:@"%d", initialQualities.count];
	}
	else if (controller.qualityType == QualityTypeArchive) {
		archiveQualities = qualities;
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kArchiveQualityIndex inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
//		self.archiveQualityLabel.text = [NSString stringWithFormat:@"%d", archiveQualities.count];
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
			title = @"Parent Folder";
			break;
			
		case 1:
			title = @"Customize Options";
			break;
			
		default:
			break;
	}
	
	return title;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	if (indexPath.section == 0) {
		SBRootDirectory *directory = [defaultDirectories objectAtIndex:indexPath.row];
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
				cell.textLabel.text = @"Initial Quality";
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", initialQualities.count];
				break;
			
			case 1:
				cell = [tableView dequeueReusableCellWithIdentifier:@"TextOptionCell"];
				cell.textLabel.text = @"Archive Quality";
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
				cell.textLabel.text = @"Status";
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
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 0) {
		if ([indexPath compare:self.parentFolderIndexPath] == NSOrderedSame) {
			return;
		}		
		
		UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
		if (newCell.accessoryType == UITableViewCellAccessoryNone) {
			newCell.accessoryType = UITableViewCellAccessoryCheckmark;
			parentFolder = [defaultDirectories objectAtIndex:indexPath.row];
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
