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

@interface SBOptionsViewController()
@property (nonatomic, strong) ATMHud *hud;
@end


@implementation SBOptionsViewController

@synthesize show;
@synthesize locationTextField;
@synthesize initialQualityLabel;
@synthesize archiveQualityLabel;
@synthesize statusLabel;
@synthesize seasonFolderSwitch;
@synthesize hud;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([locationTextField isFirstResponder]){
		[locationTextField resignFirstResponder];
	}
	
	if ([segue.identifier isEqualToString:@"InitialQualitySegue"]) {
		SBQualityViewController *vc = segue.destinationViewController;
		vc.title = @"Initial Quality";
		vc.qualityType = QualityTypeInitial;
		vc.delegate = self;
		vc.currentQuality = initialQualities;
	}
	else if ([segue.identifier isEqualToString:@"ArchiveQualitySegue"]) {
		SBQualityViewController *vc = segue.destinationViewController;
		vc.title = @"Archive Quality";
		vc.qualityType = QualityTypeArchive;
		vc.delegate = self;
		vc.currentQuality = archiveQualities;
	}
	else if ([segue.identifier isEqualToString:@"StatusSegue"]) {
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
	
	NSArray *defaultDirs = defaults.defaultDirectories;
	
	if (defaultDirs.count > 0) {
		SBRootDirectory *defaultRootDir = [defaultDirs find:^BOOL(id obj) {
			SBRootDirectory *dir = obj;
			return dir.isDefault;
		}];
		
		locationTextField.text = defaultRootDir.path;
	}
	
	initialQualities = defaults.initialQualities;
	archiveQualities = defaults.archiveQualities;
	status = defaults.status;
	
	self.initialQualityLabel.text = [NSString stringWithFormat:@"%d", initialQualities.count];
	self.archiveQualityLabel.text = [NSString stringWithFormat:@"%d", archiveQualities.count];
	self.statusLabel.text = status;
	self.seasonFolderSwitch.on = defaults.useSeasonFolders;
	
    [super viewDidLoad];
}

- (void)viewDidUnload
{
	self.initialQualityLabel = nil;
	self.archiveQualityLabel = nil;
	self.statusLabel = nil;
	self.locationTextField = nil;
	self.seasonFolderSwitch = nil;
	
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
							locationTextField.text, @"location",
							show.languageCode, @"lang",
							[NSString stringWithFormat:@"%d", seasonFolderSwitch.on], @"season_folder",
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

#pragma mark - Quality and Status
- (void)statusViewController:(SBStatusViewController *)controller didSelectStatus:(NSString *)stat {
	status = [stat copy];
	self.statusLabel.text = status;
}

- (void)qualityViewController:(SBQualityViewController *)controller didSelectQualities:(NSMutableArray *)qualities {
	if (controller.qualityType == QualityTypeInitial) {
		initialQualities = qualities;
		self.initialQualityLabel.text = [NSString stringWithFormat:@"%d", initialQualities.count];
	}
	else if (controller.qualityType == QualityTypeArchive) {
		archiveQualities = qualities;
		self.archiveQualityLabel.text = [NSString stringWithFormat:@"%d", archiveQualities.count];
	}
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 2 && indexPath.row == 0) {
		[self.hud setCaption:@"Saving defaults..."];
		[self.hud setActivity:YES];
		[self.hud show];
		
		NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSString stringWithFormat:@"%d", seasonFolderSwitch.on], @"season_folder",
								[[SBGlobal qualitiesAsCodes:initialQualities] componentsJoinedByString:@"|"], @"initial",
								[[SBGlobal qualitiesAsCodes:archiveQualities] componentsJoinedByString:@"|"], @"archive",
								[status lowercaseString], @"status",
								nil];
		
		[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandSetDefaults 
										   parameters:params 
											  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
												  NSString *result = [JSON objectForKey:@"result"];
												  
												  if ([result isEqualToString:RESULT_SUCCESS]) {
													  [self.hud hide];

													  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
													  defaults.useSeasonFolders = seasonFolderSwitch.on;
													  defaults.initialQualities = initialQualities;
													  defaults.archiveQualities = archiveQualities;
													  defaults.status = status;
													  
													  [defaults synchronize];
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
}

@end
