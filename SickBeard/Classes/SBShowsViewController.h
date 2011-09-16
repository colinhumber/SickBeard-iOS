//
//  SBShowsViewController.h
//  SickBeard
//
//  Created by Colin Humber on 8/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBShowsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	NSMutableArray *shows;
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@end
