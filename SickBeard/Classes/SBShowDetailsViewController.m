//
//  SBShowDetailsViewController.m
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBShowDetailsViewController.h"
#import "ATMHud.h"
#import "SickbeardAPIClient.h"
#import "SBShow.h"
#import "PRPAlertView.h"
#import "SBEpisode.h"
#import "OrderedDictionary.h"
#import "SBEpisodeDetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@implementation SBShowDetailsViewController

@synthesize tableView;
@synthesize show;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"EpisodeDetailsSegue"]) {
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		SBEpisodeDetailsViewController *vc = segue.destinationViewController;
	
		NSArray *seasonKeys = [seasons allKeys];
		SBEpisode *episode = [[seasons objectForKey:[seasonKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
		vc.episode = episode;
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
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	seasons = [[OrderedDictionary alloc] init];
	self.title = show.showName;
	
	UIImageView *tableHeaderView = [[UIImageView alloc] init];
	tableHeaderView.frame = CGRectMake(0, 0, 320, 60);
	[tableHeaderView setImageWithURL:[[SickbeardAPIClient sharedClient] createUrlWithEndpoint:show.bannerUrlPath] 
					placeholderImage:nil];	
	
	self.tableView.tableHeaderView = tableHeaderView;
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandSeasons
									   parameters:[NSDictionary dictionaryWithObject:show.tvdbID forKey:@"tvdbid"]
										  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  NSDictionary *dataDict = [JSON objectForKey:@"data"];
												  
												  NSArray *seasonNumbers = [[dataDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *s1, NSString *s2) {
													  if ([s1 intValue] < [s2 intValue]) {
														  return NSOrderedDescending;
													  }
													  else if ([s1 intValue] > [s2 intValue]) {
														  return NSOrderedAscending;
													  }
													  else {
														  return NSOrderedSame;
													  }
												  }];
												  
												  for (NSString *seasonNumber in seasonNumbers) {
													  NSMutableArray *episodes = [NSMutableArray array];

													  NSDictionary *seasonDict = [dataDict objectForKey:seasonNumber];
													  
													  for (NSString *episodeNumber in [seasonDict allKeys]) {
														  SBEpisode *episode = [SBEpisode itemWithDictionary:[seasonDict objectForKey:episodeNumber]];
																			
														  episode.show = show;
														  episode.season = [seasonNumber intValue];
														  episode.number = [episodeNumber intValue];
														  [episodes addObject:episode];
													  }
													  
													  [episodes sortUsingComparator:^NSComparisonResult(SBEpisode *ep1, SBEpisode *ep2) {
														  if (ep1.number > ep2.number) {
															  return NSOrderedAscending;
														  }
														  else if (ep1.number < ep2.number) {
															  return NSOrderedDescending;
														  }
														  else {
															  return NSOrderedSame;
														  }
													  }];
													  
													  [seasons setObject:episodes forKey:seasonNumber];
												  }
												  
												  dispatch_async(dispatch_get_main_queue(), ^{
													  [self.tableView reloadData];
												  });
											  }
											  else {
												  [PRPAlertView showWithTitle:@"Error retrieving shows" 
																	  message:[JSON objectForKey:@"message"] 
																  buttonTitle:@"OK"];
											  }
										  }
										  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
											  [PRPAlertView showWithTitle:@"Error retrieving show information" 
																  message:[NSString stringWithFormat:@"Could not retreive shows \n%@", error.localizedDescription] 
															  buttonTitle:@"OK"];											  
										  }];
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


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return [[seasons allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *title = @"";
	
	NSArray *keys = [seasons allKeys];
	NSString *sectionKey = [keys objectAtIndex:section];
	
	if ([sectionKey isEqualToString:@"0"]) {
		title = @"Specials";
	}
	else {
		title = [NSString stringWithFormat:@"Season %@", sectionKey];
	}
	
	return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *keys = [seasons allKeys];
	NSString *sectionKey = [keys objectAtIndex:section];
	
	return [[seasons objectForKey:sectionKey] count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"EpisodeCell"];
	
	NSArray *keys = [seasons allKeys];
	NSString *sectionKey = [keys objectAtIndex:indexPath.section];
	NSArray *episodes = [seasons objectForKey:sectionKey];
	
	SBEpisode *episode = [episodes objectAtIndex:indexPath.row];
	
	cell.textLabel.text = episode.name;
	cell.detailTextLabel.text = episode.airDate;
	
	return cell;
}


@end
