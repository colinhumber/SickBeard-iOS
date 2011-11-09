//
//  SBHistoryViewController.h
//  SickBeard
//
//  Created by Colin Humber on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBBaseViewController.h"
#import "EGORefreshTableHeaderView.h"

typedef enum {
	SBHistoryTypeSnatched,
	SBHistoryTypeDownloaded
} SBHistoryType;

@interface SBHistoryViewController : SBBaseViewController <UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate> {
	NSMutableArray *history;
	SBHistoryType historyType;
	EGORefreshTableHeaderView *refreshHeader;
}

- (IBAction)done:(id)sender;
- (IBAction)historyTypeChanged:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
