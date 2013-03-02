//
//  SBBaseViewController.m
//  SickBeard
//
//  Created by Colin Humber on 11/3/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBBaseViewController.h"
#import "NSUserDefaults+SickBeard.h"
#import "SBServer.h"

@implementation SBBaseViewController

@synthesize isDataLoading;
@synthesize loadDate;

- (void)commonInit {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	self.apiClient = [[SickbeardAPIClient alloc] initWithBaseURL:[NSURL URLWithString:defaults.server.serviceEndpointPath]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(serverBaseURLDidChange:)
												 name:SBServerURLDidChangeNotification
											   object:nil];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		[self commonInit];
	}
	
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super init];
	
	if (self) {
		[self commonInit];
	}
	
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:SBServerURLDidChangeNotification
												  object:nil];
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

#pragma mark - Server Client
- (void)serverBaseURLDidChange:(NSNotification *)notification {
	SBServer *updatedServer = notification.object;
	self.apiClient = [[SickbeardAPIClient alloc] initWithBaseURL:[NSURL URLWithString:updatedServer.serviceEndpointPath]];
}

- (SickbeardAPIClient *)apiClient {
	if (!_apiClient) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		self.apiClient = [[SickbeardAPIClient alloc] initWithBaseURL:[NSURL URLWithString:defaults.server.serviceEndpointPath]];
	}
	
	return _apiClient;
}

@end
