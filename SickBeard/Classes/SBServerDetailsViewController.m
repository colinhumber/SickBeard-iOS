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
#import "ATMHud.h"
#import "NSUserDefaults+SickBeard.h"

@interface SBServerDetailsViewController()
- (void)updateServerValues;

@property (nonatomic, strong) ATMHud *hud;
@end

@implementation SBServerDetailsViewController

@synthesize nameTextField;
@synthesize hostTextField;
@synthesize portTextField;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize apiKeyTextField;
@synthesize hud;
@synthesize server;
//@synthesize managedObjectContext;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.title = @"Server";

	if (![NSUserDefaults standardUserDefaults].serverHasBeenSetup) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
																				   style:UIBarButtonItemStyleDone 
																				  target:self 
																				  action:@selector(saveServer)];
	}
	
	self.server = [NSUserDefaults standardUserDefaults].server;
	
	if (server) {
		nameTextField.text = server.name;
		hostTextField.text = server.host;
		portTextField.text = [NSString stringWithFormat:@"%d", server.port];
		usernameTextField.text = server.username;
		passwordTextField.text = server.password;
		apiKeyTextField.text = server.apiKey;
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
	[self setHud:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - Actions -
- (void)updateServerValues {
	server.name = nameTextField.text;
	server.host = hostTextField.text;
	server.port = [portTextField.text intValue];
	server.username = usernameTextField.text;
	server.password = passwordTextField.text;
	server.apiKey = apiKeyTextField.text;
}

- (void)close {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveServer {
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
		[currentResponder resignFirstResponder];

		[self.hud setCaption:@"Saving server"];
		[self.hud setActivity:YES];
		
		if (isHudShowing) {
			[self.hud update];
		}
		else {
			[self.hud show];
		}
		
		RunAfterDelay(2, ^{
			[NSUserDefaults standardUserDefaults].serverHasBeenSetup = YES;
			[NSUserDefaults standardUserDefaults].server = server;
			[SickbeardAPIClient sharedClient].currentServer = server;
			[self.hud setCaption:@"Server saved"];
			[self.hud setActivity:NO];
			[self.hud setImage:[UIImage imageNamed:@"19-check"]];
			[self.hud performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:YES];
		
			RunAfterDelay(3, ^{
				[self close];
			});
		});
		
//		[self.managedObjectContext saveRemoteWithBlock:^(BOOL saved, NSError *error) {
//			if (saved) {
//				[NSUserDefaults standardUserDefaults].serverHasBeenSetup = YES;
//				[self.hud setCaption:@"Server saved"];
//				[self.hud setActivity:NO];
//				[self.hud setImage:[UIImage imageNamed:@"19-check"]];
//				[self.hud performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:YES];
//				
//				RunOnMainThread(NO, ^{
//					[self performSelector:@selector(close) withObject:nil afterDelay:1];
//				});
//			}
//			else {
//				[PRPAlertView showWithTitle:@"Error saving server" 
//									message:[NSString stringWithFormat:@"An error has occured saving your server. \n%@", error.localizedDescription] 
//								buttonTitle:@"OK"];
//
//			}
//		}];
	}
}

- (ATMHud*)hud {
	if (!hud) {
		hud = [[ATMHud alloc] init];
		[self.view addSubview:hud.view];
		
		// reset the origin to 0,0 to account for contentOffset of table view
		CGRect frame = hud.view.frame;
		frame.origin = CGPointZero;
		hud.view.frame = frame;
	}
	
	return hud;
}

- (void)hudDidAppear:(ATMHud *)_hud {
	isHudShowing = YES;
}

- (void)hudDidDisappear:(ATMHud *)_hud {
	isHudShowing = NO;
}


#pragma mark - UITextFieldDelegate -
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	currentResponder = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == apiKeyTextField) {
		[textField resignFirstResponder];
	}
	
	return YES;
}

#pragma mark - UITableViewDelegate -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 0) {
		return;
	}
	else {
		if (indexPath.row == 0) {
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
				[currentResponder resignFirstResponder];
//				self.hud = [[[ATMHud alloc] init] autorelease];
				[self.hud setCaption:@"Validating server"];
				[self.hud setActivity:YES];
//				[self.view addSubview:hud.view];
				
				
				
				[self.hud show];
				[[SickbeardAPIClient sharedClient] pingServer:server
													  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
														  if ([JSON valueForKeyPath:@"result"]) {
															  [self.hud setCaption:@"Server is up!"];
															  [self.hud setActivity:NO];
															  [self.hud setImage:[UIImage imageNamed:@"19-check"]];
															  [self.hud update];
															  [self.hud hideAfter:2.0];
															  
															  [self performSelector:@selector(setHud:) withObject:nil afterDelay:4.0];
														  }
													  }
													  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
														  [self.hud setCaption:[NSString stringWithFormat:@"Unable to connect to Sick Beard at %@", server.serviceEndpointPath]];
														  [self.hud setActivity:NO];
														  [self.hud update];
														  [self.hud hideAfter:2.0];
														  
														  [self performSelector:@selector(setHud:) withObject:nil afterDelay:4.0];														  
													  }];
			}
		}
	}
}


@end
