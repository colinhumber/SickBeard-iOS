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

@property (nonatomic, strong) SBShow *show;
@property (nonatomic, strong) IBOutlet UITextField *locationTextField;
@property (nonatomic, strong) IBOutlet UILabel *initialQualityLabel;
@property (nonatomic, strong) IBOutlet UILabel *archiveQualityLabel;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UISwitch *seasonFolderSwitch;


@end
