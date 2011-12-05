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

@synthesize tableView;

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
    [super viewDidLoad];

	self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.navigationController.toolbar.frame.size.height, 0);
	self.tableView.scrollIndicatorInsets = self.tableView.contentInset;

	refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
	refreshHeader.delegate = self;
	refreshHeader.defaultInsets = self.tableView.contentInset;
	[self.tableView addSubview:refreshHeader];
	[refreshHeader refreshLastUpdatedDate];
}

- (void)viewDidAppear:(BOOL)animated {
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

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Loading
- (void)loadData {
	[super loadData];

	[SVProgressHUD showWithStatus:@"Loading shows"];
	
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
													  NSLog(@"No shows");
												  }
											  }
											  else {
												  [PRPAlertView showWithTitle:@"Error retrieving shows" 
																	  message:[JSON objectForKey:@"message"] 
																  buttonTitle:@"OK"];
											  }
										
											  [self finishDataLoad:nil];
											  [self.tableView reloadData];
											  [refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
										  }
										  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
											  [PRPAlertView showWithTitle:@"Error retrieving shows" 
																  message:error.localizedDescription 
															  buttonTitle:@"OK"];			
											  
											  [self finishDataLoad:error];
											  [refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
										  }];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
	[refreshHeader egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[refreshHeader egoRefreshScrollViewDidEndDragging:scrollView];	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {	
	[self loadData];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {	
	return self.isDataLoading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
	return self.loadDate; // should return date data source was last changed
}


#pragma mark - SBAddShowDelegate
- (void)didAddShow {
	[self dismissViewControllerAnimated:YES completion:^{
		[self loadData];
	}];
}

- (void)didCancelAddShow {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions
- (void)addShow {
	[self performSegueWithIdentifier:@"AddShowSegue" sender:nil];
}

- (IBAction)refresh:(id)sender {
	[self loadData];
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
	cell.statusLabel.text = show.status;
	cell.nextEpisodeAirdateLabel.text = show.nextEpisodeDate != nil ? [show.nextEpisodeDate displayString] : @"No airdate found";

	[cell findiTunesArtworkForShow:show.sanitizedShowName];
//	[cell.posterImageView setImageWithURL:[[SickbeardAPIClient sharedClient] posterURL:show.tvdbID] 
//						 placeholderImage:nil];	
		
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row % 2 == 0) {
		cell.backgroundColor = RGBCOLOR(245, 241, 226); 
	}
	else {
		cell.backgroundColor = RGBCOLOR(223, 218, 206); 		
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		SBShow *show = [shows objectAtIndex:indexPath.row];
		NSDictionary *params = [NSDictionary dictionaryWithObject:show.tvdbID forKey:@"tvdbid"];

		[SVProgressHUD showWithStatus:@"Deleting show"];
//		[self.hud setActivity:YES];
//		[self.hud setCaption:@"Deleting show..."];
//		[self.hud show];
		
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
													  [PRPAlertView showWithTitle:@"Could not delete show" 
																		  message:[JSON objectForKey:@"message"] 
																	  buttonTitle:@"Okay"];
												  }				
												  
												  [SVProgressHUD dismiss];
												  //[self.hud hide];
											  }
											  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
												  [PRPAlertView showWithTitle:@"Error deleting show" 
																	  message:error.localizedDescription 
																  buttonTitle:@"Okay"];			
												  [SVProgressHUD dismiss];
												  //[self.hud hide];
											  }];
	}
}


@end
