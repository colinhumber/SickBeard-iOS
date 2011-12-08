//
//  SBBaseTableViewController.m
//  SickBeard
//
//  Created by Colin Humber on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBBaseTableViewController.h"


@implementation SBBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
}

- (void)refresh:(id)sender{
}

- (void)loadData {
	
}

@end
