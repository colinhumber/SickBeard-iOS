//
//  SBSettingsViewController.m
//  SickBeard
//
//  Created by Colin Humber on 8/29/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBSettingsViewController.h"
#import "PRPAlertView.h"
#import "SBSectionHeaderView.h"
#import "CRNavigationController.h"
#import "SBWebViewController.h"

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
		vc.qualityType = QualityTypeArchive;
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
	
	[TestFlight passCheckpoint:@"Viewed settings"];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
	self.initialQualityLabel.text = [NSString stringWithFormat:@"%d", defaults.initialQualities.count];
	self.archiveQualityLabel.text = [NSString stringWithFormat:@"%d", defaults.archiveQualities.count];
	self.statusLabel.text = [defaults.status capitalizedString];
	self.seasonFolderSwitch.on = defaults.useSeasonFolders;
}

- (void)viewDidUnload {
	self.initialQualityLabel = nil;
	self.archiveQualityLabel = nil;
	self.statusLabel = nil;
	self.seasonFolderSwitch = nil;
	
    [super viewDidUnload];
}

- (BOOL)shouldAutorotate {
	return NO;
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
	self.statusLabel.text = [stat capitalizedString];
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

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 2) {
		if (indexPath.row == 0) {
			if (![MFMailComposeViewController canSendMail]) {
				[PRPAlertView showWithTitle:NSLocalizedString(@"Unable to send mail", @"Unable to send mail") 
									message:NSLocalizedString(@"Mail has not been setup on this device", @"Mail has not been setup on this device")
								buttonTitle:NSLocalizedString(@"OK", @"OK")];
				return;
			}
			
			MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
			mailer.mailComposeDelegate = self;
			[mailer setSubject:@"Sick Beard for iOS Feedback"];
			[mailer setMessageBody:[SBGlobal feedbackBody] isHTML:NO];
			[mailer setToRecipients:@[@"sickbeardios@gmail.com"]];
			[self presentViewController:mailer animated:YES completion:^{
				[TestFlight passCheckpoint:@"Send feedback"];
			}];
		}
		else if (indexPath.row == 1) {
			[TestFlight passCheckpoint:@"Clicked Twitter"];
			
			SBWebViewController *webViewController = [[SBWebViewController alloc] initWithAddress:@"http://twitter.com/sickbeardios"];
			
			[self presentViewController:webViewController animated:YES completion:nil];
		}
		else if (indexPath.row == 2) {
			[TestFlight passCheckpoint:@"Clicked Donate"];

			SBWebViewController *webViewController = [[SBWebViewController alloc] initWithAddress:kDonateLink];
			
			[self presentViewController:webViewController animated:YES completion:nil];
		}
	}
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self dismissViewControllerAnimated:YES completion:nil];
	
	if (result == MFMailComposeResultFailed) {
		[PRPAlertView showWithTitle:NSLocalizedString(@"Unable to send email", @"Unable to send email") 
							message:error.localizedDescription 
						buttonTitle:NSLocalizedString(@"OK", @"OK")];
	}
}

@end
