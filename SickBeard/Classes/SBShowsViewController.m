//
//  SBShowsViewController.m
//  SickBeard
//
//  Created by Colin Humber on 8/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBShowsViewController.h"
#import "SBShowDetailsViewController.h"
#import "SBAddShowViewController.h"
#import "SickbeardAPIClient.h"
#import "SBShow.h"
#import "PRPAlertView.h"
#import "ShowCell.h"
#import "NSUserDefaults+SickBeard.h"
#import "NSDate+Utilities.h"


@implementation SBShowsViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"ShowDetailsSegue"]) {
		SBShowDetailsViewController *detailsController = [segue destinationViewController];
		detailsController.show = [shows objectAtIndex:[self.tableView indexPathForSelectedRow].row];
	}
	else if ([segue.identifier isEqualToString:@"AddShowSegue"]) {
		UINavigationController *navController = [segue destinationViewController];
		SBAddShowViewController *addShowController = (SBAddShowViewController*)navController.topViewController;
		addShowController.delegate = self;
	}
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.navigationController.toolbar.frame.size.height, 0);
	self.tableView.scrollIndicatorInsets = self.tableView.contentInset;

	[super viewDidLoad];
	
	self.emptyView.emptyLabel.text = NSLocalizedString(@"No shows found", @"No shows found");
}

- (void)viewDidAppear:(BOOL)animated {
	[TestFlight passCheckpoint:@"Viewed show list"];
	
	[super viewWillAppear:animated];
	
	if ([self tableView:self.tableView numberOfRowsInSection:0] > 0) {
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
	}
	else {
		if ([NSUserDefaults standardUserDefaults].serverHasBeenSetup) {
			if (!shows) {
				[shows removeAllObjects];
				[self loadData];
			}
		}		
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	self.editing = NO;
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Loading
- (void)loadData {
	[super loadData];

	[SVProgressHUD showWithStatus:NSLocalizedString(@"Loading shows", @"Loading shows")];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"name", @"sort", nil];
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandShows 
									   parameters:params
										  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  shows = [[NSMutableArray alloc] init];
												  
												  NSDictionary *dataDict = [JSON objectForKey:@"data"];
												  
												  if (dataDict.allKeys.count > 0) {
													  for (NSString *key in [dataDict allKeys]) {
														  SBShow *show = [SBShow itemWithDictionary:[dataDict objectForKey:key]];
														  show.showName = key;
														  [shows addObject:show];
													  }
													  
													  NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"showName" ascending:YES];
													  [shows sortUsingDescriptors:[NSArray arrayWithObject:sorter]];
												  }
												  else {
													  [self showEmptyView:YES animated:YES];
													  NSLog(@"No shows");
												  }
											  }
											  else {
												  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving shows", @"Error retrieving shows") 
																	  message:[JSON objectForKey:@"message"] 
																  buttonTitle:NSLocalizedString(@"OK", @"OK")];
											  }
										
											  [self finishDataLoad:nil];
											  [self.tableView reloadData];
											  [self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
										  }
										  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
											  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving shows", @"Error retrieving shows") 
																  message:error.localizedDescription 
															  buttonTitle:NSLocalizedString(@"OK", @"OK")];			
											  
											  [self finishDataLoad:error];
											  [self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
										  }];
}

#pragma mark - SBAddShowDelegate
- (void)didAddShow {
	[TestFlight passCheckpoint:@"Did add show"];
	[self dismissViewControllerAnimated:YES completion:^{
		[self loadData];
	}];
}

- (void)didCancelAddShow {
	[TestFlight passCheckpoint:@"Cancel add show"];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions
- (void)addShow {
	[self performSegueWithIdentifier:@"AddShowSegue" sender:nil];
	[TestFlight passCheckpoint:@"Adding show"];
}

- (IBAction)refresh:(id)sender {
	[self loadData];
	[TestFlight passCheckpoint:@"Refreshed shows list"];
}

#pragma mark - UITableViewDelegate
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	[self.parentViewController setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return shows.count;
}


- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ShowCell *cell = (ShowCell*)[tv dequeueReusableCellWithIdentifier:@"ShowCell"];
	
	SBShow *show = [shows objectAtIndex:indexPath.row];
	cell.showNameLabel.text = show.showName;	
	cell.networkLabel.text = show.network;
	cell.statusLabel.text = [SBShow showStatusAsString:show.status];
	cell.nextEpisodeAirdateLabel.text = show.nextEpisodeDate != nil ? [show.nextEpisodeDate displayString] : NSLocalizedString(@"No airdate found", @"No airdate found");

	[cell.showImageView setImageWithURL:[[SickbeardAPIClient sharedClient] posterURLForTVDBID:show.tvdbID] 
					   placeholderImage:[UIImage imageNamed:@"placeholder"]];
	
	return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		SBShow *show = [shows objectAtIndex:indexPath.row];
		NSDictionary *params = [NSDictionary dictionaryWithObject:show.tvdbID forKey:@"tvdbid"];

		[SVProgressHUD showWithStatus:NSLocalizedString(@"Deleting show", @"Deleting show")];
		
		[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandShowDelete 
										   parameters:params 
											  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
												  NSString *result = [JSON objectForKey:@"result"];
												  
												  if ([result isEqualToString:RESULT_SUCCESS]) {
													  [shows removeObjectAtIndex:indexPath.row];
													  [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
																			withRowAnimation:UITableViewRowAnimationAutomatic];
												  }
												  else {
													  [PRPAlertView showWithTitle:NSLocalizedString(@"Could not delete show", @"Could not delete show") 
																		  message:[JSON objectForKey:@"message"] 
																	  buttonTitle:NSLocalizedString(@"OK", @"OK")];
												  }				
												  
												  [SVProgressHUD dismiss];
											  }
											  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
												  [PRPAlertView showWithTitle:NSLocalizedString(@"Error deleting show", @"Error deleting show") 
																	  message:error.localizedDescription 
																  buttonTitle:NSLocalizedString(@"OK", @"OK")];			
												  [SVProgressHUD dismiss];
											  }];
	}
}


@end
