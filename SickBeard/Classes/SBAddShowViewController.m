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
#import "SBSectionHeaderView.h"
#import <SVProgressHUD/SVProgressHUD.h>

#define SHOW_NAME_TAG 900
#define PICKER_TAG 901

@interface SBAddShowViewController () <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate> {
	BOOL _isSearching;
	BOOL _languagePickerViewVisible;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIPickerView *languagePickerView;
@property (nonatomic, strong) UITextField *showNameTextField;
@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) NSString *currentLanguage;

@end

@implementation SBAddShowViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"AddNewShowSegue"]) {
		SBOptionsViewController *vc = segue.destinationViewController;
		vc.delegate = self.delegate;
		
		NSIndexPath *ip = [self.tableView indexPathForSelectedRow];
		
		SBShow *show = [[SBShow alloc] init];
		show.tvdbID = self.results[ip.row][@"tvdbid"];
		show.showName = self.results[ip.row][@"name"];
		show.languageCode = [SBGlobal validLanguages][self.currentLanguage];
		
		vc.show = show;
	}
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

	self.currentLanguage = @"English";
	
	_languagePickerViewVisible = NO;
	self.languagePickerView.hidden = YES;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(hidePicker)
												 name:UIKeyboardWillShowNotification
											   object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[SVProgressHUD dismiss];
}

- (BOOL)shouldAutorotate {
	return NO;
}

#pragma mark - Actions
- (void)languageChanged:(UIPickerView *)picker {
	
}

- (void)showPicker {
	if ([self.showNameTextField isFirstResponder]) {
		[self.showNameTextField resignFirstResponder];
	}
	
	NSIndexPath *languageCellIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:languageCellIndexPath];
	cell.detailTextLabel.textColor = cell.detailTextLabel.tintColor;
	
	[self.languagePickerView selectRow:[[[SBGlobal validLanguages] allKeys] indexOfObject:self.currentLanguage]
						   inComponent:0
							  animated:NO];

	_languagePickerViewVisible = YES;
	[self.tableView beginUpdates];
	[self.tableView endUpdates];
	
	self.languagePickerView.hidden = NO;
	self.languagePickerView.alpha = 0.0f;
	
	[UIView animateWithDuration:0.25f animations:^{
		self.languagePickerView.alpha = 1.0f;
	}];
	
	NSIndexPath *pickerIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
	[self.tableView scrollToRowAtIndexPath:pickerIndexPath
						  atScrollPosition:UITableViewScrollPositionTop
								  animated:YES];
}

- (void)hidePicker {
	if (_languagePickerViewVisible) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
		
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		cell.detailTextLabel.textColor = RGBCOLOR(49, 89, 136);
		
		_languagePickerViewVisible = NO;
		[self.tableView beginUpdates];
		[self.tableView endUpdates];
		
		[UIView animateWithDuration:0.25f animations:^{
			self.languagePickerView.alpha = 0.0f;
		} completion:^(BOOL finished) {
			self.languagePickerView.hidden = YES;
		}];
	}
}

- (IBAction)performSearch:(id)sender {
	if (self.showNameTextField.text.length == 0) {
		[PRPAlertView showWithTitle:NSLocalizedString(@"Missing information", @"Missing information") 
							message:NSLocalizedString(@"Please enter a show to search", @"Please enter a show to search")
						buttonTitle:NSLocalizedString(@"OK", @"OK")];
		return;
	}
	
	[SVProgressHUD showWithStatus:NSLocalizedString(@"Searching TVDB", @"Searching TVDB")];
	
	if ([self.showNameTextField isFirstResponder]) {
		[self.showNameTextField resignFirstResponder];
	}
	
	[self hidePicker];

	NSDictionary *params = @{@"name": self.showNameTextField.text,
							@"lang": [SBGlobal validLanguages][self.currentLanguage]};
	
	_isSearching = YES;
	
	[self.apiClient runCommand:SickBeardCommandSearchTVDB
									   parameters:params 
										  success:^(NSURLSessionDataTask *task, id JSON) {
											  NSString *result = JSON[@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  dispatch_async(dispatch_get_main_queue(), ^{
													  [SVProgressHUD dismiss];
													  //[self.hud hide]; 
												  });
												  
												  self.results = JSON[@"data"][@"results"];
												  [self.tableView reloadData];
											  }
										  }
										  failure:^(NSURLSessionDataTask *task, NSError *error) {
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
	if (self.results) {
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
	return section == 0 ? 0 : 25;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 3;
	}
	else if (section == 1) {
		return self.results.count == 0 ? 1 : self.results.count;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			cell = [tv dequeueReusableCellWithIdentifier:@"ShowNameCell"];
			self.showNameTextField = (UITextField*)[cell viewWithTag:SHOW_NAME_TAG];
			
			if (!_isSearching) {
				[self.showNameTextField becomeFirstResponder];
				_isSearching = NO;
			}
		}
		else if (indexPath.row == 1) {
			cell = [tv dequeueReusableCellWithIdentifier:@"LanguageCell"];
			cell.detailTextLabel.text = self.currentLanguage;
		}
		else {
			cell = [tv dequeueReusableCellWithIdentifier:@"PickerCell"];
			self.languagePickerView = (UIPickerView*)[cell viewWithTag:PICKER_TAG];
		}
	}
	else {
		cell = [tv dequeueReusableCellWithIdentifier:@"ResultCell"];
		
		if (self.results.count == 0) {
			cell.textLabel.text = NSLocalizedString(@"No results found", @"No results found");
			cell.detailTextLabel.text = nil;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		else {
			NSDictionary *result = self.results[indexPath.row];
			
			cell.textLabel.text = result[@"name"];
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			id airDate = result[@"first_aired"];
			if (airDate == [NSNull null] || [airDate length] == 0) {
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 2) {
		return _languagePickerViewVisible ? 163.0f : 0.0f;
	}
	
	return 44.0f;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 2) {
		return nil;
	}
	
	return indexPath;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	if (indexPath.section == 0 && indexPath.row == 1) {
		[tv deselectRowAtIndexPath:indexPath animated:YES];

		if (!_languagePickerViewVisible) {
			[self showPicker];
		}
		else {
			[self hidePicker];
		}
		
		return;
	}
	else if (indexPath.section == 1) {
		if (self.results.count > 0) {
			[self performSegueWithIdentifier:@"AddNewShowSegue" sender:nil];
		}
	}
	
	[self hidePicker];
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
	return [[SBGlobal validLanguages] allKeys][row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	self.currentLanguage = [[SBGlobal validLanguages] allKeys][row];

	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
	
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	cell.detailTextLabel.text = self.currentLanguage;

}



@end
