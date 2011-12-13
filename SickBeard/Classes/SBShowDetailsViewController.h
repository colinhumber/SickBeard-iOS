//
//  SBShowDetailsViewController.h
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBBaseTableViewController.h"
#import "SBEpisodeDetailsViewController.h"

@class SBShow;
@class SBShowDetailsHeaderView;
@class OrderedDictionary;

@interface SBShowDetailsViewController : SBBaseTableViewController <UIActionSheetDelegate, SBEpisodeDetailsDataSource> {
	OrderedDictionary *seasons;
	
	struct {
		int menuIsShowing:1;
		int menuIsHiding:1;
	} _menuFlags;
	NSIndexPath *menuIndexPath;
}

- (IBAction)showActions;

@property (nonatomic, strong) SBShow *show;
@property (nonatomic, strong) IBOutlet SBShowDetailsHeaderView *detailsHeaderView;

@end


