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

@interface SBSettingsViewController : UITableViewController <SBQualityViewControllerDelegate, SBStatusViewControllerDelegate>

@property (nonatomic, retain) IBOutlet UILabel *initialQualityLabel;
@property (nonatomic, retain) IBOutlet UILabel *archiveQualityLabel;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UISwitch *seasonFolderSwitch;

@end
