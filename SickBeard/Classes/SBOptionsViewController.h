//
//  SBOptionsViewController.h
//  SickBeard
//
//  Created by Colin Humber on 9/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBQualityViewController.h"
#import "SBStatusViewController.h"

@class SBShow;

@interface SBOptionsViewController : UITableViewController <SBQualityViewControllerDelegate, SBStatusViewControllerDelegate, UITextFieldDelegate> {
	NSMutableArray *initialQualities;
	NSMutableArray *archiveQualities;
	NSString *status;
}

@property (nonatomic, retain) SBShow *show;
@property (nonatomic, retain) IBOutlet UITextField *locationTextField;
@property (nonatomic, retain) IBOutlet UILabel *initialQualityLabel;
@property (nonatomic, retain) IBOutlet UILabel *archiveQualityLabel;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UISwitch *seasonFolderSwitch;


@end
