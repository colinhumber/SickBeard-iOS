//
//  SBCreditsViewController.m
//  SickBeard
//
//  Created by Colin Humber on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
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


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return credits.allKeys.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *sectionKey = [self.credits.allKeys objectAtIndex:section];
	NSDictionary *creditDict = [self.credits objectForKey:sectionKey];

	return [creditDict objectForKey:@"groupName"];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString *title = [self tableView:tableView titleForHeaderInSection:section];
	
	SBSectionHeaderView *header = [[SBSectionHeaderView alloc] init];
	header.sectionLabel.text = title;
	return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *sectionKey = [self.credits.allKeys objectAtIndex:section];
	NSDictionary *creditDict = [self.credits objectForKey:sectionKey];
	
	return [[creditDict objectForKey:@"items"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *sectionKey = [self.credits.allKeys objectAtIndex:indexPath.section];
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
	
	return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSString *sectionKey = [self.credits.allKeys objectAtIndex:indexPath.section];
	NSDictionary *creditDict = [self.credits objectForKey:sectionKey];
	NSArray *creds = [creditDict objectForKey:@"items"];
	NSDictionary *credit = [creds objectAtIndex:indexPath.row];
	
	NSString *urlPath = [credit objectForKey:@"url"];
	if (urlPath.length > 0) {
		SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:urlPath];
		webViewController.toolbar.tintColor = nil;
		webViewController.toolbar.barStyle = UIBarStyleBlack;
		webViewController.availableActions = SVWebViewControllerAvailableActionsCopyLink | SVWebViewControllerAvailableActionsMailLink | SVWebViewControllerAvailableActionsOpenInSafari;		
		[self presentViewController:webViewController animated:YES completion:nil];
	}
}

@end
