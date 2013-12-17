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
	
	if (self.server) {
		[self setInitialServerValues];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[TSMessage setDefaultViewController:self.navigationController];
}

- (BOOL)shouldAutorotate {
	return NO;
}

#pragma mark - Actions
- (void)enableFields:(BOOL)enabled {
	self.nameTextField.enabled = enabled;
	self.hostTextField.enabled = enabled;
	self.portTextField.enabled = enabled;
	self.pathTextField.enabled = enabled;
	self.sslSwitch.enabled = enabled;
	self.apiKeyTextField.enabled = enabled;
	self.usernameTextField.enabled = enabled;
	self.passwordTextField.enabled = enabled;
}

- (void)setInitialServerValues {
	self.nameTextField.text = self.server.name;
	self.hostTextField.text = self.server.host;
	self.portTextField.text = [NSString stringWithFormat:@"%d", self.server.port];
	self.pathTextField.text = self.server.path;
	self.sslSwitch.on = self.server.useSSL;
	self.apiKeyTextField.text = self.server.apiKey;
	self.usernameTextField.text = self.server.proxyUsername;
	self.passwordTextField.text = self.server.proxyPassword;
}

- (void)updateServerValues {
	NSString *host = [self.hostTextField.text stringByReplacingOccurrencesOfString:@"http://" withString:@""];
	host = [host stringByReplacingOccurrencesOfString:@"https://" withString:@""];
	
	self.server.name = self.nameTextField.text;
	self.server.host = host;
	self.server.port = [self.portTextField.text intValue];
	self.server.path = [self.pathTextField.text stringByReplacingOccurrencesOfString:@"/" withString:@""];
	self.server.useSSL = self.sslSwitch.on;
	self.server.apiKey = self.apiKeyTextField.text;
	self.server.proxyUsername = self.usernameTextField.text;
	self.server.proxyPassword = self.passwordTextField.text;
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
	if (!self.server) {
		self.server = [[SBServer alloc] init];
	}
	
	[TestFlight passCheckpoint:saveOnSuccess ? @"Saving server" : @"Testing server"];
	
	[self updateServerValues];
	
	if (![self.server isValid]) {
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
		 SickbeardAPIClient *client = [[SickbeardAPIClient alloc] initWithBaseURL:[NSURL URLWithString:self.server.serviceEndpointPath]];
		 [client runCommand:SickBeardCommandPing
				 parameters:nil
					success:^(NSURLSessionDataTask *task, id JSON) {
						[SVProgressHUD dismiss];
						
						NSString *result = JSON[@"result"];
						
						if ([result isEqualToString:RESULT_SUCCESS]) {
							if (saveOnSuccess) {
								[[NSNotificationCenter defaultCenter] postNotificationName:SBServerURLDidChangeNotification object:self.server];
								
								SickbeardAPIClient *client = [[SickbeardAPIClient alloc] initWithBaseURL:[NSURL URLWithString:self.server.serviceEndpointPath]];
								[client loadDefaults];
								
								RunAfterDelay(2, ^{
									[NSUserDefaults standardUserDefaults].serverHasBeenSetup = YES;
									[NSUserDefaults standardUserDefaults].server = self.server;
									[NSUserDefaults standardUserDefaults].shouldUpdateShowList = YES;
									
									[TSMessage showNotificationWithTitle:NSLocalizedString(@"Server saved", @"Server saved")
																	type:TSMessageNotificationTypeSuccess];
									
									if (_flags.initialSetup) {
										RunAfterDelay(1.5, ^{
											[self close];
										});
									}
								});
							}
							else {
								[TSMessage showNotificationWithTitle:NSLocalizedString(@"Server validated", @"Server validated")
																type:TSMessageNotificationTypeSuccess];
							}
						}
						else if ([result isEqualToString:RESULT_DENIED]) {
							[TSMessage showNotificationWithTitle:JSON[@"message"]
															type:TSMessageNotificationTypeError];
						}
						
						[SVProgressHUD dismiss];
					}
					failure:^(NSURLSessionDataTask *task, NSError *error) {
						[SVProgressHUD dismiss];

						[TSMessage showNotificationWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Unable to connect to Sick Beard (%@)", @"Unable to connect to Sick Beard (%@)"), self.server.serviceEndpointPath]
														type:TSMessageNotificationTypeError];
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
	if (textField == self.apiKeyTextField) {
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
