//
//  SBAddShowViewController.m
//  SickBeard
//
//  Created by Colin Humber on 9/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBAddShowViewController.h"
#import "ATMHud.h"
#import "SickbeardAPIClient.h"
#import "PRPAlertView.h"
#import "UIImageView+AFNetworking.h"
#import "SBShow.h"
#import "SBOptionsViewController.h"

@interface SBAddShowViewController()
@property (nonatomic, strong) ATMHud *hud;
@end

@implementation SBAddShowViewController

@synthesize tableView;
@synthesize languagePickerView;
@synthesize showNameTextField;
@synthesize hud;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"AddNewShowSegue"]) {
		SBOptionsViewController *vc = segue.destinationViewController;
		
		NSIndexPath *ip = [self.tableView indexPathForSelectedRow];
		
		SBShow *show = [[SBShow alloc] init];
		show.tvdbID = [[results objectAtIndex:ip.row] objectAtIndex:0];
		show.showName = [[results objectAtIndex:ip.row] objectAtIndex:1];
		show.languageCode = [[SBGlobal validLanguages] objectForKey:currentLanguage];
		
		vc.show = show;
	}
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	currentLanguage = @"English";

	self.hud = [[ATMHud alloc] init];
	[self.view addSubview:self.hud.view];
	
    [super viewDidLoad];
}


- (void)viewDidAppear:(BOOL)animated {
	[self.languagePickerView selectRow:[[[SBGlobal validLanguages] allKeys] indexOfObject:currentLanguage]  
						   inComponent:0 
							  animated:NO];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
	self.tableView = nil;
	self.languagePickerView = nil;
	self.showNameTextField = nil;
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions
- (void)showPicker {
	if ([showNameTextField isFirstResponder]) {
		[showNameTextField resignFirstResponder];
	}
	
	[UIView animateWithDuration:0.4
					 animations:^{
						 self.languagePickerView.transform = CGAffineTransformMakeTranslation(0, -self.languagePickerView.frame.size.height);
					 }];
}

- (void)hidePicker {
	[UIView animateWithDuration:0.4
					 animations:^{
						 self.languagePickerView.transform = CGAffineTransformIdentity;
					 }];	
}

- (IBAction)performSearch:(id)sender {
	[self.hud setCaption:@"Searching TVDB..."];
	[self.hud setActivity:YES];
	[self.hud show];
	
	if ([showNameTextField isFirstResponder]) {
		[showNameTextField resignFirstResponder];
	}
	
	[self hidePicker];

	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							showNameTextField.text, @"name",
							[[SBGlobal validLanguages] objectForKey:currentLanguage], @"lang",
							nil];
	
	isSearching = YES;
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandShowSearchTVDB 
									   parameters:params 
										  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  dispatch_async(dispatch_get_main_queue(), ^{
													  [self.hud hide]; 
												  });
												  
												  results = [[JSON objectForKey:@"data"] objectForKey:@"results"];
												  [self.tableView reloadData];
											  }
										  }
										  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
											  [PRPAlertView showWithTitle:@"Error searching for show" 
																  message:[NSString stringWithFormat:@"Could not perform search \n%@", error.localizedDescription] 
															  buttonTitle:@"OK"];											  

										  }];
}

- (IBAction)cancel:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	
	[self performSearch:nil];
	return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	if (results) {
		return 2;
	}
	
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Search";
	}
	else {
		return @"TVDB Results";
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 2;
	}
	else if (section == 1) {
		return results.count == 0 ? 1 : results.count;
	}
	
	return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			cell = [tv dequeueReusableCellWithIdentifier:@"ShowNameCell"];
//			cell.textLabel.text = @"Show Name";
			self.showNameTextField = (UITextField*)[cell viewWithTag:900];
			
			if (!isSearching) {
				[showNameTextField becomeFirstResponder];
				isSearching = NO;
			}
		}
		else {
			cell = [tv dequeueReusableCellWithIdentifier:@"LanguageCell"];
//			cell.textLabel.text = @"Language";
			cell.detailTextLabel.text = currentLanguage;
		}
	}
	else {
		cell = [tv dequeueReusableCellWithIdentifier:@"ResultCell"];
		
		if (results.count == 0) {
			cell.textLabel.text = @"No results found";
			cell.detailTextLabel.text = nil;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		else {
			NSArray *result = [results objectAtIndex:indexPath.row];
			
			cell.textLabel.text = [result objectAtIndex:1];
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			id airDate = [result objectAtIndex:2];
			if (airDate == [NSNull null]) {
				airDate = @"Unknown air date";
			}
			else {
				airDate = [NSString stringWithFormat:@"Started on %@", airDate];
			}
			
			cell.detailTextLabel.text = airDate;
		}
	}
	
	return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tv deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 0 && indexPath.row == 1) {
		[self showPicker];
	}
	else if (indexPath.section == 1) {
		if (results.count > 0) {
			[self performSegueWithIdentifier:@"AddNewShowSegue" sender:nil];
		}
	}
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [[[SBGlobal validLanguages] allKeys] count];
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [[[SBGlobal validLanguages] allKeys] objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	currentLanguage = [[[SBGlobal validLanguages] allKeys] objectAtIndex:row];
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];

	[self hidePicker];
}



@end
