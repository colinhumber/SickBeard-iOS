//
//  SBServerDetailsViewController.m
//  SickBeard
//
//  Created by Colin Humber on 8/29/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBServerDetailsViewController.h"
#import "SickbeardAPIClient.h"
#import "SBServer.h"
#import "PRPAlertView.h"
#import "NSUserDefaults+SickBeard.h"
#import "SBStaticTableViewCell.h"
#import "SBCreditsViewController.h"
#import "SVProgressHUD.h"

@interface SBServerDetailsViewController()
- (void)updateServerValues;
- (void)setInitialServerValues;
- (void)enableFields:(BOOL)enabled;
- (void)validateServer:(BOOL)saveOnSuccess;
- (void)_validateServer:(BOOL)saveOnSuccess;
@end

@implementation SBServerDetailsViewController

@synthesize nameTextField;
@synthesize hostTextField;
@synthesize portTextField;
@synthesize pathTextField;
@synthesize sslSwitch;
@synthesize apiKeyTextField;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize server;

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		_flags.didCancel = NO;
		_flags.initialSetup = ![NSUserDefaults standardUserDefaults].serverHasBeenSetup;
	}
	
	return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = NSLocalizedString(@"Server", @"Server");
	self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
	
	if (_flags.initialSetup) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done")
																				  style:UIBarButtonItemStyleDone 
																				 target:self 
																				 action:@selector(saveServer)];
	}
	else {
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
		[self enableFields:NO];
	}
	
	self.server = [NSUserDefaults standardUserDefaults].server;
	
	if (server) {
		[self setInitialServerValues];
	}
	
	for (int section = 0; section < [self numberOfSectionsInTableView:self.tableView]; section++) {
		int numberOfRows = [self tableView:self.tableView numberOfRowsInSection:section];
		
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numberOfRows - 1 inSection:section];
		SBStaticTableViewCell *cell = (SBStaticTableViewCell*)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
		cell.lastCell = YES;
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions
//- (void)showHelp {
//	SBHelpViewController *helpController = [self.storyboard instantiateViewControllerWithIdentifier:@"SBHelpViewController"];
//	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:helpController];
//	[self presentViewController:nav animated:YES completion:nil];
//}

- (void)enableFields:(BOOL)enabled {
	nameTextField.enabled = enabled;
	hostTextField.enabled = enabled;
	portTextField.enabled = enabled;
	pathTextField.enabled = enabled;
	sslSwitch.enabled = enabled;
	apiKeyTextField.enabled = enabled;
	usernameTextField.enabled = enabled;
	passwordTextField.enabled = enabled;
}

- (void)setInitialServerValues {
	nameTextField.text = server.name;
	hostTextField.text = server.host;
	portTextField.text = [NSString stringWithFormat:@"%d", server.port];
	pathTextField.text = server.path;
	sslSwitch.on = server.useSSL;
	apiKeyTextField.text = server.apiKey;
	usernameTextField.text = server.proxyUsername;
	passwordTextField.text = server.proxyPassword;
}

- (void)updateServerValues {
	NSString *host = [hostTextField.text stringByReplacingOccurrencesOfString:@"http://" withString:@""];
	host = [host stringByReplacingOccurrencesOfString:@"https://" withString:@""];
	
	server.name = nameTextField.text;
	server.host = host;
	server.port = [portTextField.text intValue];
	server.path = [pathTextField.text stringByReplacingOccurrencesOfString:@"/" withString:@""];
	server.useSSL = sslSwitch.on;
	server.apiKey = apiKeyTextField.text;
	server.proxyUsername = usernameTextField.text;
	server.proxyPassword = passwordTextField.text;
}

- (void)cancelEdit {
	_flags.didCancel = YES;
	[currentResponder resignFirstResponder];
	currentResponder = nil;
	[self setInitialServerValues];
	[self setEditing:NO animated:YES];
}

- (void)close {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)validateServer:(BOOL)saveOnSuccess {
	if (!server) {
		self.server = [[SBServer alloc] init];
	}
	
	[TestFlight passCheckpoint:saveOnSuccess ? @"Saving server" : @"Testing server"];
	
	[self updateServerValues];
	
	if (![server isValid]) {
		[PRPAlertView showWithTitle:NSLocalizedString(@"Invalid server", @"Invalid server")
							message:NSLocalizedString(@"Some information you have provided is invalid. Please check again.", @"Some information you have provided is invalid. Please check again.") 
						buttonTitle:NSLocalizedString(@"OK", @"OK")];
	}
	else {
		NSTimeInterval delay = 0.0;
		
		if (currentResponder && [currentResponder isFirstResponder]) {
			delay = 0.5;
			[currentResponder resignFirstResponder];
			currentResponder = nil;	
		}
		
		RunAfterDelay(delay, ^{		// allow the keyboard to hide before displaying the HUD
			[self _validateServer:saveOnSuccess];
		});
	}
}

- (void)_validateServer:(BOOL)saveOnSuccess {
	 [SVProgressHUD showWithStatus:NSLocalizedString(@"Validating API key", @"Validating API key") 
						  maskType:SVProgressHUDMaskTypeGradient];
	 
	 RunAfterDelay(0.5, ^{
		 SickbeardAPIClient *client = [[SickbeardAPIClient alloc] initWithBaseURL:[NSURL URLWithString:server.serviceEndpointPath]];
		 [client runCommand:SickBeardCommandPing
				 parameters:nil
					success:^(NSURLSessionDataTask *task, id JSON) {
						[SVProgressHUD dismiss];
						
						NSString *result = JSON[@"result"];
						
						if ([result isEqualToString:RESULT_SUCCESS]) {
							if (saveOnSuccess) {
								[[NSNotificationCenter defaultCenter] postNotificationName:SBServerURLDidChangeNotification object:server];
								
								SickbeardAPIClient *client = [[SickbeardAPIClient alloc] initWithBaseURL:[NSURL URLWithString:server.serviceEndpointPath]];
								[client loadDefaults];
								
								RunAfterDelay(2, ^{
									[NSUserDefaults standardUserDefaults].serverHasBeenSetup = YES;
									[NSUserDefaults standardUserDefaults].server = server;
									[NSUserDefaults standardUserDefaults].shouldUpdateShowList = YES;
									
									[[SBNotificationManager sharedManager] queueNotificationWithText:NSLocalizedString(@"Server saved", @"Server saved")
																								type:SBNotificationTypeSuccess];
									
									if (_flags.initialSetup) {
										RunAfterDelay(1.5, ^{
											[self close];
										});
									}
								});
							}
							else {
								[[SBNotificationManager sharedManager] queueNotificationWithText:NSLocalizedString(@"Server validated", @"Server validated")
																							type:SBNotificationTypeSuccess];
							}
						}
						else if ([result isEqualToString:RESULT_DENIED]) {
							[[SBNotificationManager sharedManager] queueNotificationWithText:JSON[@"message"]
																						type:SBNotificationTypeError];
						}
						
						[SVProgressHUD dismiss];
					}
					failure:^(NSURLSessionDataTask *task, NSError *error) {
						[SVProgressHUD dismiss];

						[[SBNotificationManager sharedManager] queueNotificationWithText:[NSString stringWithFormat:NSLocalizedString(@"Unable to connect to Sick Beard (%@)", @"Unable to connect to Sick Beard (%@)"), server.serviceEndpointPath]
																					type:SBNotificationTypeError];
					}];
	 });
}

- (void)saveServer {
	[self validateServer:YES];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	currentResponder = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == apiKeyTextField) {
		[textField resignFirstResponder];
	}
	
	return YES;
}

#pragma mark - UITableViewDelegate
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:YES];
	
	[self enableFields:editing];
	
	if (editing) {
		_flags.didCancel = NO;
		[self.nameTextField becomeFirstResponder];
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																							  target:self 
																							  action:@selector(cancelEdit)];
	}
	else {
		if (!_flags.didCancel) {
			[self saveServer];
		}
		self.navigationItem.leftBarButtonItem = nil;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 0) {
		[self validateServer:NO];
	}
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

@end
