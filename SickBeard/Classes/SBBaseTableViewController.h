//
//  SBBaseTableViewController.h
//  SickBeard
//
//  Created by Colin Humber on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBHudViewController.h"

@interface SBBaseTableViewController : UITableViewController <SBHudViewController>

- (void)loadData;

@end
