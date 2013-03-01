//
//  SBOptionsViewController.h
//  SickBeard
//
//  Created by Colin Humber on 9/8/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBBaseTableViewController.h"
#import "SBQualityViewController.h"
#import "SBStatusViewController.h"
#import "SBAddShowDelegate.h"

@class SBShow;
@class SBRootDirectory;

@interface SBOptionsViewController : SBBaseTableViewController <SBQualityViewControllerDelegate, SBStatusViewControllerDelegate, UITextFieldDelegate> {
	NSMutableArray *initialQualities;
	NSMutableArray *archiveQualities;
	NSMutableArray *defaultDirectories;
	NSString *status;
	SBRootDirectory *parentFolder;
	BOOL useSeasonFolders;
}

- (IBAction)useSeasonFoldersChanged:(id)sender;

@property (nonatomic, strong) SBShow *show;
@property (nonatomic, weak) id<SBAddShowDelegate> delegate;

@end
