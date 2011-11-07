//
//  SBBaseTableViewController.m
//  SickBeard
//
//  Created by Colin Humber on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBBaseTableViewController.h"


@implementation SBBaseTableViewController

@synthesize hud;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.hud = [[ATMHud alloc] init];
	[self.view addSubview:self.hud.view];
}

- (void)refresh:(id)sender{
}

- (void)loadData {
	
}

@end
