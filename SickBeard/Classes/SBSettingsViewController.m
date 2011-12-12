//
//  SBSettingsViewController.m
//  SickBeard
//
//  Created by Colin Humber on 8/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBSettingsViewController.h"
#import "PRPAlertView.h"
#import "SVModalWebViewController.h"

@implementation SBSettingsViewController

@synthesize initialQualityLabel;
@synthesize archiveQualityLabel;
@synthesize statusLabel;
@synthesize seasonFolderSwitch;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	NSString *identifier = segue.identifier;
	
	if ([identifier isEqualToString:@"InitialQualitySegue"]) {
		SBQualityViewController *vc = segue.destinationViewController;
		vc.qualityType = QualityTypeInitial;
		vc.delegate = self;
		vc.currentQuality = [NSUserDefaults standardUserDefaults].initialQualities;
	}
	else if ([identifier isEqualToString:@"ArchiveQualitySegue"]) {
		SBQualityViewController *vc = segue.destinationViewController;
		vc.qualityType = QualityTypeInitial;
		vc.delegate = self;
		vc.currentQuality = [NSUserDefaults standardUserDefaults].archiveQualities;
	}
	else if ([identifier isEqualToString:@"StatusSegue"]) {
		SBStatusViewController *vc = segue.destinationViewController;
		vc.delegate = self;
		vc.currentStatus = [NSUserDefaults standardUserDefaults].status;
	}
	else if ([identifier isEqualToString:@"ServerSegue"]) {
		
	}
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
	[TestFlight passCheckpoint:@"Viewed settings"];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
	self.initialQualityLabel.text = [NSString stringWithFormat:@"%d", defaults.initialQualities.count];
	self.archiveQualityLabel.text = [NSString stringWithFormat:@"%d", defaults.archiveQualities.count];
	self.statusLabel.text = defaults.status;
	self.seasonFolderSwitch.on = defaults.useSeasonFolders;
}

- (void)viewDidUnload
{
	self.initialQualityLabel = nil;
	self.archiveQualityLabel = nil;
	self.statusLabel = nil;
	self.seasonFolderSwitch = nil;
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions
- (IBAction)done:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)seasonFolderSwitched:(id)sender {
	[NSUserDefaults standardUserDefaults].useSeasonFolders = self.seasonFolderSwitch.on; 
}

#pragma mark - Quality and Status
- (void)statusViewController:(SBStatusViewController *)controller didSelectStatus:(NSString *)stat {
	[NSUserDefaults standardUserDefaults].status = stat;
	self.statusLabel.text = stat;
}

- (void)qualityViewController:(SBQualityViewController *)controller didSelectQualities:(NSMutableArray *)qualities {
	[TestFlight passCheckpoint:@"Changed quality settings"];
	
	if (controller.qualityType == QualityTypeInitial) {
		[NSUserDefaults standardUserDefaults].initialQualities = qualities;
		self.initialQualityLabel.text = [NSString stringWithFormat:@"%d", qualities.count];
	}
	else if (controller.qualityType == QualityTypeArchive) {
		[NSUserDefaults standardUserDefaults].archiveQualities = qualities;
		self.archiveQualityLabel.text = [NSString stringWithFormat:@"%d", qualities.count];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 2) {
		if (indexPath.row == 0) {
			if (![MFMailComposeViewController canSendMail]) {
				[PRPAlertView showWithTitle:@"Unable to send mail" message:@"Mail has not been setup on this device" buttonTitle:@"OK"];
				return;
			}
			
			MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
			mailer.mailComposeDelegate = self;
			[mailer setSubject:@"Sick Beard for iOS Feedback"];
			[mailer setMessageBody:[SBGlobal feedbackBody] isHTML:NO];
			[mailer setToRecipients:[NSArray arrayWithObject:@"sickbeardios@gmail.com"]];
			[self presentViewController:mailer animated:YES completion:^{
				[TestFlight passCheckpoint:@"Send feedback"];
			}];
		}
		else if (indexPath.row == 1) {
			[TestFlight passCheckpoint:@"Clicked Twitter"];
			SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:@"http://twitter.com/sickbeardios"];
			webViewController.availableActions = SVWebViewControllerAvailableActionsCopyLink | SVWebViewControllerAvailableActionsMailLink | SVWebViewControllerAvailableActionsOpenInSafari;
			[self presentViewController:webViewController animated:YES completion:nil];
		}
	}
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self dismissViewControllerAnimated:YES completion:nil];
	
	if (result == MFMailComposeResultFailed) {
		[PRPAlertView showWithTitle:@"Unable to send email" message:[error localizedDescription] buttonTitle:@"OK"];
	}
}

@end
