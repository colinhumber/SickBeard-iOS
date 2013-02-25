//
//  SBCreditsViewController.m
//  SickBeard
//
//  Created by Colin Humber on 12/16/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBCreditsViewController.h"
#import "SBSectionHeaderView.h"
#import "SBCellBackground.h"
#import "SVModalWebViewController.h"

@interface SBCreditsViewController ()
@property (nonatomic, strong) NSDictionary *credits;
@end

@implementation SBCreditsViewController

@synthesize credits;

#pragma mark - View lifecycle

- (void)viewDidLoad {
	self.enableEmptyView = NO;
	self.enableRefreshHeader = NO;
	
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"Credits", @"Credits");

	NSString *path = [[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"plist"];
	self.credits = [NSDictionary dictionaryWithContentsOfFile:path];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSArray*)sortedKeys {
	return [credits.allKeys sort:^NSComparisonResult(id obj1, id obj2) {
		return [obj1 compare:obj2 options:NSCaseInsensitiveSearch | NSNumericSearch];
	}];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return credits.allKeys.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {	
	NSString *sectionKey = [[self sortedKeys] objectAtIndex:section];
	NSDictionary *creditDict = [self.credits objectForKey:sectionKey];

	return [creditDict objectForKey:@"groupName"];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString *title = [self tableView:tableView titleForHeaderInSection:section];
	
	if (title.length == 0) {
		return nil;
	}
	
	SBSectionHeaderView *header = [[SBSectionHeaderView alloc] init];
	header.sectionLabel.text = title;
	return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	NSString *title = [self tableView:tableView titleForHeaderInSection:section];
	
	if (title.length == 0) {
		return 0;
	}
	
	return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *sectionKey = [[self sortedKeys] objectAtIndex:section];
	NSDictionary *creditDict = [self.credits objectForKey:sectionKey];
	
	return [[creditDict objectForKey:@"items"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *sectionKey = [[self sortedKeys] objectAtIndex:indexPath.section];
	NSDictionary *creditDict = [self.credits objectForKey:sectionKey];
	NSArray *creds = [creditDict objectForKey:@"items"];
	NSDictionary *credit = [creds objectAtIndex:indexPath.row];
	
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"CreditCell"];
	
	SBCellBackground *backgroundView = [[SBCellBackground alloc] init];
	backgroundView.grouped = YES;
	backgroundView.applyShadow = NO;
	
	SBCellBackground *selectedBackgroundView = [[SBCellBackground alloc] init];
	selectedBackgroundView.grouped = YES;
	selectedBackgroundView.applyShadow = NO;
	selectedBackgroundView.selected = YES;
	
	if (indexPath.row == [self tableView:tv numberOfRowsInSection:indexPath.section] - 1) {
		backgroundView.lastCell = YES;
		backgroundView.applyShadow = YES;
		selectedBackgroundView.lastCell = YES;
		selectedBackgroundView.applyShadow = YES;
	}
	
	cell.backgroundView = backgroundView;
	cell.selectedBackgroundView = selectedBackgroundView;

	cell.textLabel.text = [credit objectForKey:@"role"];
	cell.detailTextLabel.text = [credit objectForKey:@"name"];
	
	NSURL *url = [NSURL URLWithString:[credit objectForKey:@"url"]];
	if ([[url scheme] isEqualToString:@"sbSegue"]) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSString *sectionKey = [[self sortedKeys] objectAtIndex:indexPath.section];
	NSDictionary *creditDict = [self.credits objectForKey:sectionKey];
	NSArray *creds = [creditDict objectForKey:@"items"];
	NSDictionary *credit = [creds objectAtIndex:indexPath.row];
	
	NSURL *url = [NSURL URLWithString:[credit objectForKey:@"url"]];
	if (url) {
		if ([[url scheme] rangeOfString:@"http"].location != NSNotFound) {
			SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithURL:url];
			webViewController.toolbar.tintColor = nil;
			webViewController.toolbar.barStyle = UIBarStyleBlack;
			webViewController.availableActions = SVWebViewControllerAvailableActionsCopyLink | SVWebViewControllerAvailableActionsMailLink | SVWebViewControllerAvailableActionsOpenInSafari;		
			[self presentViewController:webViewController animated:YES completion:nil];
		}
		else if ([[url scheme] isEqualToString:@"sbSegue"]) {
			[self performSegueWithIdentifier:[url host] sender:nil];
		}
	}
}

@end
