//
//  SBEpisodesViewController.h
//  SickBeard
//
//  Created by Colin Humber on 8/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBBaseViewController.h"
#import "EGORefreshTableHeaderView.h"

@class OrderedDictionary;

@interface SBEpisodesViewController : SBBaseViewController <EGORefreshTableHeaderDelegate> {
	OrderedDictionary *comingEpisodes;
	EGORefreshTableHeaderView *refreshHeader;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
