//
//  SBBaseViewController.m
//  SickBeard
//
//  Created by Colin Humber on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBBaseViewController.h"

@implementation SBBaseViewController

@synthesize hud;
@synthesize isDataLoading;
@synthesize loadDate;

- (void)viewDidLoad {
	[super viewDidLoad];
	
//	self.hud = [[ATMHud alloc] init];
//	[self.view addSubview:self.hud.view];
}

- (void)refresh:(id)sender {
}

- (void)loadData {	
	self.isDataLoading = YES;
}

- (void)finishDataLoad:(NSError*)error {
	self.isDataLoading = NO;
	//[self.hud hide];
	[SVProgressHUD dismiss];
	
	if (!error) {
		self.loadDate = [NSDate date];
	}
}

@end
