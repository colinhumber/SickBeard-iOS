//
//  SBCreditsViewController.m
//  SickBeard
//
//  Created by Colin Humber on 12/16/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBCreditsViewController.h"
#import "SBSectionHeaderView.h"
#import "SBWebViewController.h"

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

- (BOOL)shouldAutorotate {
	return NO;
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
	NSString *sectionKey = [self sortedKeys][section];
	NSDictionary *creditDict = (self.credits)[sectionKey];

	return creditDict[@"groupName"];
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
	
	return 25;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *sectionKey = [self sortedKeys][section];
	NSDictionary *creditDict = (self.credits)[sectionKey];
	
	return [creditDict[@"items"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *sectionKey = [self sortedKeys][indexPath.section];
	NSDictionary *creditDict = (self.credits)[sectionKey];
	NSArray *creds = creditDict[@"items"];
	NSDictionary *credit = creds[indexPath.row];
	
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"CreditCell"];

	cell.textLabel.text = credit[@"role"];
	cell.detailTextLabel.text = credit[@"name"];
	
	NSURL *url = [NSURL URLWithString:credit[@"url"]];
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
	
	NSString *sectionKey = [self sortedKeys][indexPath.section];
	NSDictionary *creditDict = (self.credits)[sectionKey];
	NSArray *creds = creditDict[@"items"];
	NSDictionary *credit = creds[indexPath.row];
	
	NSURL *url = [NSURL URLWithString:credit[@"url"]];
	if (url) {
		if ([[url scheme] rangeOfString:@"http"].location != NSNotFound) {
			SBWebViewController *webViewController = [[SBWebViewController alloc] initWithURL:url];
			
			[self presentViewController:webViewController animated:YES completion:nil];
		}
		else if ([[url scheme] isEqualToString:@"sbSegue"]) {
			[self performSegueWithIdentifier:[url host] sender:nil];
		}
	}
}

@end
