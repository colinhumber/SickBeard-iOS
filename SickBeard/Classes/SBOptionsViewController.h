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
@class SBRootDirectory;

@interface SBOptionsViewController : UITableViewController <SBQualityViewControllerDelegate, SBStatusViewControllerDelegate, UITextFieldDelegate> {
	NSMutableArray *initialQualities;
	NSMutableArray *archiveQualities;
	NSMutableArray *defaultDirectories;
	NSString *status;
	SBRootDirectory *parentFolder;
	BOOL useSeasonFolders;
}

- (IBAction)useSeasonFoldersChanged:(id)sender;

@property (nonatomic, strong) SBShow *show;
//@property (nonatomic, strong) IBOutlet UILabel *initialQualityLabel;
//@property (nonatomic, strong) IBOutlet UILabel *archiveQualityLabel;
//@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
//@property (nonatomic, strong) IBOutlet UISwitch *seasonFolderSwitch;


@end
