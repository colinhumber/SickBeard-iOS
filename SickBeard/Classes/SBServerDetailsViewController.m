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
@property (nonatomic, retain) ATMHud *hud;
@end

@implementation SBServerDetailsViewController

@synthesize nameTextField;
@synthesize hostTextField;
@synthesize portTextField;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize apiKeyTextField;
@synthesize currentSwitch;
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

- (void)dealloc {
    [nameTextField release];
    [hostTextField release];
    [portTextField release];
    [usernameTextField release];
    [passwordTextField release];
    [apiKeyTextField release];
	[currentSwitch release];
//	[managedObjectContext release];
	[hud release];
    [super dealloc];
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

	if (![NSUserDefaults standardUserDefaults].serverHasBeenSetup) {
		self.title = @"Setup Server";
		self.currentSwitch.enabled = NO;
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done" 
																				   style:UIBarButtonItemStyleDone 
																				  target:self 
																				  action:@selector(saveServer)] autorelease];
	}
	
	self.server = [NSUserDefaults standardUserDefaults].server;
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setNameTextField:nil];
    [self setHostTextField:nil];
    [self setPortTextField:nil];
    [self setUsernameTextField:nil];
    [self setPasswordTextField:nil];
    [self setApiKeyTextField:nil];
	[self setCurrentSwitch:nil];
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
	server.isCurrent = currentSwitch.on;
}

- (void)close {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveServer {
	if (!server) {
		self.server = [[[SBServer alloc] init] autorelease];
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

#pragma mark - UITableViewDelegate -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 0) {
		return;
	}
	else {
		if (indexPath.row == 0) {
			if (!server) {
				self.server = [[[SBServer alloc] init] autorelease];
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
													  success:^(id JSON) {
														  if ([JSON valueForKeyPath:@"result"]) {
															  [self.hud setCaption:@"Server is up!"];
															  [self.hud setActivity:NO];
															  [self.hud setImage:[UIImage imageNamed:@"19-check"]];
															  [self.hud update];
															  [self.hud hideAfter:2.0];
															  
															  [self performSelector:@selector(setHud:) withObject:nil afterDelay:4.0];
														  }
													  }
													  failure:^(NSError *error) {
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


@end
