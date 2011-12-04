//
//  SBServerDetailsViewController.m
//  SickBeard
//
//  Created by Colin Humber on 8/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBServerDetailsViewController.h"
#import "SickbeardAPIClient.h"
#import "SBServer.h"
#import "SBServer+SickBeardAdditions.h"
#import "PRPAlertView.h"
#import "NSUserDefaults+SickBeard.h"

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
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize apiKeyTextField;
@synthesize server;
//@synthesize managedObjectContext;

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		_flags.didCancel = NO;
		_flags.initialSetup = ![NSUserDefaults standardUserDefaults].serverHasBeenSetup;
;
	}
	
	return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = @"Server";

	if (_flags.initialSetup) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
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
	else {
#if DEBUG
		nameTextField.text = @"Home";
		hostTextField.text = @"colinhumber.dyndns.org";
		portTextField.text = @"8081";
		apiKeyTextField.text = @"aefc639b299bbbe8ed0e526ef83d415c";
		usernameTextField.text = @"colinhumber";
		passwordTextField.text = @"Square99";
#endif		
	}
	
}

- (void)viewDidUnload
{
    [self setNameTextField:nil];
    [self setHostTextField:nil];
    [self setPortTextField:nil];
    [self setUsernameTextField:nil];
    [self setPasswordTextField:nil];
    [self setApiKeyTextField:nil];
	//[self setHud:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions
- (void)enableFields:(BOOL)enabled {
	nameTextField.enabled = enabled;
	hostTextField.enabled = enabled;
	portTextField.enabled = enabled;
	usernameTextField.enabled = enabled;
	passwordTextField.enabled = enabled;
	apiKeyTextField.enabled = enabled;
}

- (void)setInitialServerValues {
	nameTextField.text = server.name;
	hostTextField.text = server.host;
	portTextField.text = [NSString stringWithFormat:@"%d", server.port];
	usernameTextField.text = server.username;
	passwordTextField.text = server.password;
	apiKeyTextField.text = server.apiKey;
}

- (void)updateServerValues {
	server.name = nameTextField.text;
	server.host = hostTextField.text;
	server.port = [portTextField.text intValue];
	server.username = usernameTextField.text;
	server.password = passwordTextField.text;
	server.apiKey = apiKeyTextField.text;
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
	
	[self updateServerValues];
	
	if (![server isValid]) {
		[PRPAlertView showWithTitle:@"Invalid server" 
							message:@"Some information you have provided is invalid. Please check again." 
						buttonTitle:@"OK"];
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
	[SVProgressHUD showWithStatus:@"Validating username and password"];			
	
	[NSUserDefaults standardUserDefaults].temporaryServer = server;
	
	[[SickbeardAPIClient sharedClient] validateServerCredentials:server 
														 success:^(id object) {
															 [NSUserDefaults standardUserDefaults].temporaryServer = nil;
															 
															 [SVProgressHUD setStatus:@"Validating API key"];
															 
															 RunAfterDelay(0.5, ^{
																 [[SickbeardAPIClient sharedClient] pingServer:server
																									   success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
																										   NSString *result = [JSON objectForKey:@"result"];
																										   
																										   if ([result isEqualToString:RESULT_SUCCESS]) {
																											   if (saveOnSuccess) {
																												   [[SickbeardAPIClient sharedClient] loadDefaults:server];
																												   
																												   RunAfterDelay(2, ^{
																													   [NSUserDefaults standardUserDefaults].serverHasBeenSetup = YES;
																													   [NSUserDefaults standardUserDefaults].server = server;
																													   [SickbeardAPIClient sharedClient].currentServer = server;
																													   
																													   [SVProgressHUD dismissWithSuccess:@"Server saved"];
																													   
																													   if (_flags.initialSetup) {
																														   RunAfterDelay(1.5, ^{
																															   [self close];
																														   });
																													   }
																												   });
																											   }
																											   else {
																												   [SVProgressHUD dismissWithSuccess:@"Server validated"];
																											   }
																										   }
																										   else if ([result isEqualToString:RESULT_DENIED]) {
																											   [SVProgressHUD dismissWithError:[JSON objectForKey:@"message"]];
																											   [self.hud hideAfter:1.0];
																										   }
																									   }
																									   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
																										   [SVProgressHUD dismissWithError:[NSString stringWithFormat:@"Unable to connect to Sick Beard at %@", server.serviceEndpointPath] 
																																afterDelay:1];
																										   [self.hud hideAfter:1.0];
																									   }];
															 });
														 }
														 failure:^(NSHTTPURLResponse *response, NSError *error) {
															 if ([response statusCode] == 401) {
																 [SVProgressHUD dismissWithError:@"Username and password invalid" afterDelay:2];
															 }
															 else {
																 [SVProgressHUD dismissWithError:[NSString stringWithFormat:@"Unable to connect to Sick Beard at %@", server.serviceEndpointPath] 
																					  afterDelay:2];
															 }
														 }];
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
		return;
	}
	else {
		if (indexPath.row == 0) {
			[self validateServer:NO];
		}
	}
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

@end
