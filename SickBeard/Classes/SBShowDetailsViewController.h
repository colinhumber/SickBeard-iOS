//
//  SBShowDetailsViewController.h
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBShow;
@class OrderedDictionary;

@interface SBShowDetailsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
	OrderedDictionary *seasons;
}

- (IBAction)showActions;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) SBShow *show;

@end
