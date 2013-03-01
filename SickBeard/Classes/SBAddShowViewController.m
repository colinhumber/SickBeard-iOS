//
//  SBAddShowViewController.m
//  SickBeard
//
//  Created by Colin Humber on 9/7/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBAddShowViewController.h"
#import "SickbeardAPIClient.h"
#import "PRPAlertView.h"
#import "UIImageView+AFNetworking.h"
#import "SBShow.h"
#import "SBOptionsViewController.h"
#import "SBCellBackground.h"
#import "SBSectionHeaderView.h"
#import "SVProgressHUD.h"

@implementation SBAddShowViewController

@synthesize tableView;
@synthesize languagePickerView;
@synthesize showNameTextField;
@synthesize delegate;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"AddNewShowSegue"]) {
		SBOptionsViewController *vc = segue.destinationViewController;
		vc.delegate = self.delegate;
		
		NSIndexPath *ip = [self.tableView indexPathForSelectedRow];
		
		SBShow *show = [[SBShow alloc] init];
		show.tvdbID = [[results objectAtIndex:ip.row] objectForKey:@"tvdbid"];
		show.showName = [[results objectAtIndex:ip.row] objectForKey:@"name"];
		show.languageCode = [[SBGlobal validLanguages] objectForKey:currentLanguage];
		
		vc.show = show;
	}
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	currentLanguage = @"English";
	self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];

	self.languagePickerView.top = self.view.height - self.navigationController.navigationBar.height;
	
    [super viewDidLoad];
}


- (void)viewDidAppear:(BOOL)animated {
	[self.languagePickerView selectRow:[[[SBGlobal validLanguages] allKeys] indexOfObject:currentLanguage]  
						   inComponent:0 
							  animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[SVProgressHUD dismiss];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	self.tableView = nil;
	self.languagePickerView = nil;
	self.showNameTextField = nil;
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
	if (showNameTextField.text.length == 0) {
		[PRPAlertView showWithTitle:NSLocalizedString(@"Missing information", @"Missing information") 
							message:NSLocalizedString(@"Please enter a show to search", @"Please enter a show to search")
						buttonTitle:NSLocalizedString(@"OK", @"OK")];
		return;
	}
	
	[SVProgressHUD showWithStatus:NSLocalizedString(@"Searching TVDB", @"Searching TVDB")];
	
	if ([showNameTextField isFirstResponder]) {
		[showNameTextField resignFirstResponder];
	}
	
	[self hidePicker];

	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							showNameTextField.text, @"name",
							[[SBGlobal validLanguages] objectForKey:currentLanguage], @"lang",
							nil];
	
	isSearching = YES;
	
	[self.apiClient runCommand:SickBeardCommandSearchTVDB
									   parameters:params 
										  success:^(AFHTTPRequestOperation *operation, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  dispatch_async(dispatch_get_main_queue(), ^{
													  [SVProgressHUD dismiss];
													  //[self.hud hide]; 
												  });
												  
												  results = [[JSON objectForKey:@"data"] objectForKey:@"results"];
												  [self.tableView reloadData];
											  }
										  }
										  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
											  [PRPAlertView showWithTitle:NSLocalizedString(@"Error searching for show", @"Error searching for show") 
																  message:[NSString stringWithFormat:NSLocalizedString(@"Could not perform search \n%@", @"Could not perform search \n%@"), error.localizedDescription] 
															  buttonTitle:NSLocalizedString(@"OK", @"OK")];											  

										  }];
}

- (IBAction)cancel:(id)sender {
	[self.delegate didCancelAddShow];
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
		return NSLocalizedString(@"Search", @"Search");
	}
	else {
		return NSLocalizedString(@"TVDB Results", @"TVDB Results");
	}
}

- (UIView*)tableView:(UITableView *)tv viewForHeaderInSection:(NSInteger)section {
	NSString *title = [self tableView:tv titleForHeaderInSection:section];
	
	SBSectionHeaderView *header = [[SBSectionHeaderView alloc] init];
	header.sectionLabel.text = title;
	return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 50;
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
			self.showNameTextField = (UITextField*)[cell viewWithTag:900];
			
			if (!isSearching) {
				[showNameTextField becomeFirstResponder];
				isSearching = NO;
			}
		}
		else {
			cell = [tv dequeueReusableCellWithIdentifier:@"LanguageCell"];
			cell.detailTextLabel.text = currentLanguage;
		}
	}
	else {
		cell = [tv dequeueReusableCellWithIdentifier:@"ResultCell"];
		
		if (results.count == 0) {
			cell.textLabel.text = NSLocalizedString(@"No results found", @"No results found");
			cell.detailTextLabel.text = nil;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		else {
			NSDictionary *result = [results objectAtIndex:indexPath.row];
			
			cell.textLabel.text = [result objectForKey:@"name"];
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			id airDate = [result objectForKey:@"first_aired"];
			if (airDate == [NSNull null] || [airDate length] == 0) {
				airDate = @"Unknown air date";
			}
			else {
				airDate = [NSString stringWithFormat:@"Started on %@", airDate];
			}
			
			cell.detailTextLabel.text = airDate;
		}
	}
	
	SBCellBackground *backgroundView = [[SBCellBackground alloc] init];
	backgroundView.grouped = YES;
	backgroundView.applyShadow = NO;
	
	SBCellBackground *selectedBackgroundView = [[SBCellBackground alloc] init];
	selectedBackgroundView.grouped = YES;
	selectedBackgroundView.applyShadow = NO;
	selectedBackgroundView.selected = YES;
	
	if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
		backgroundView.lastCell = YES;
		backgroundView.applyShadow = YES;
		selectedBackgroundView.lastCell = YES;
		selectedBackgroundView.applyShadow = YES;
	}
	
	cell.backgroundView = backgroundView;
	cell.selectedBackgroundView = selectedBackgroundView;
	
	return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	if (indexPath.section == 0 && indexPath.row == 1) {
		[self showPicker];
	}
	else if (indexPath.section == 1) {
		if (results.count > 0) {
			[self performSegueWithIdentifier:@"AddNewShowSegue" sender:nil];
		}
	}
	
	[tv deselectRowAtIndexPath:indexPath animated:YES];
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
