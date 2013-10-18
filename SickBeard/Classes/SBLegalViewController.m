//
//  SBLegalViewController.m
//  SickBeard
//
//  Created by Colin Humber on 12/21/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBLegalViewController.h"


@implementation SBLegalViewController

@synthesize webView;

#pragma mark - View lifecycle
- (void)viewDidLoad {
	self.title = NSLocalizedString(@"Legal", @"Legal");
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"legal" ofType:@"html"];
	[self.webView loadHTMLString:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] baseURL:nil]; 
    [super viewDidLoad];
}


- (void)viewDidUnload {
    [super viewDidUnload];
	self.webView = nil;
}

- (BOOL)shouldAutorotate {
	return NO;
}

@end
