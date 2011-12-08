//
//  SBSettingsViewController.h
//  SickBeard
//
//  Created by Colin Humber on 8/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBQualityViewController.h"
#import "SBStatusViewController.h"
#import <MessageUI/MessageUI.h>

@interface SBSettingsViewController : UITableViewController <SBQualityViewControllerDelegate, SBStatusViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *initialQualityLabel;
@property (nonatomic, strong) IBOutlet UILabel *archiveQualityLabel;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UISwitch *seasonFolderSwitch;

- (IBAction)done:(id)sender;
- (IBAction)seasonFolderSwitched:(id)sender;

@end
