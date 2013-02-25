//
//  SBBaseViewController.m
//  SickBeard
//
//  Created by Colin Humber on 11/3/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBBaseViewController.h"

@implementation SBBaseViewController

@synthesize isDataLoading;
@synthesize loadDate;

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)refresh:(id)sender {
}

- (void)loadData {	
	self.isDataLoading = YES;
}

- (void)finishDataLoad:(NSError*)error {
	self.isDataLoading = NO;

	[SVProgressHUD dismiss];
	
	if (!error) {
		self.loadDate = [NSDate date];
	}
}

@end
