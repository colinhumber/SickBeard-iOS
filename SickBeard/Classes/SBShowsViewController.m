//
//  SBShowsViewController.m
//  SickBeard
//
//  Created by Colin Humber on 8/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBShowsViewController.h"
#import "SickbeardAPIClient.h"
#import "ATMHud.h"
#import "SBShow.h"
#import "PRPAlertView.h"
#import "SBShowDetailsViewController.h"
#import "NSUserDefaults+SickBeard.h"
#import "UIImageView+AFNetworking.h"
#import "ShowCell.h"

@interface SBShowsViewController()
@property (nonatomic, retain) ATMHud *hud;
@end


@implementation SBShowsViewController

@synthesize tableView;
@synthesize hud;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"ShowDetailsSegue"]) {
		SBShowDetailsViewController *detailsController = [segue destinationViewController];
		detailsController.show = [shows objectAtIndex:[self.tableView indexPathForSelectedRow].row];
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

- (void)dealloc {
	[shows release];
	[tableView release];
	[super dealloc];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	shows = [[NSMutableArray alloc] init];

    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
	if ([NSUserDefaults standardUserDefaults].serverHasBeenSetup) {
		[shows removeAllObjects];
		
		[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandShows 
										   parameters:nil 
											  success:^(id JSON) {
												  NSString *result = [JSON objectForKey:@"result"];
												  
												  if ([result isEqualToString:RESULT_SUCCESS]) {
													  NSDictionary *dataDict = [JSON objectForKey:@"data"];
													  
													  for (NSString *key in [dataDict allKeys]) {
														  SBShow *show = [SBShow itemWithDictionary:[dataDict objectForKey:key]];
														  show.tvdbID = key;
														  [shows addObject:show];
													  }
												  }
												  else {
													  [PRPAlertView showWithTitle:@"Error retrieving shows" 
																		  message:[JSON objectForKey:@"message"] 
																	  buttonTitle:@"OK"];
												  }
												  
												  [self.tableView reloadData];
											  }
											  failure:^(NSError *error) {
												  [PRPAlertView showWithTitle:@"Error retrieving shows" 
																	  message:[NSString stringWithFormat:@"Could not retreive shows \n%@", error.localizedDescription] 
																  buttonTitle:@"OK"];											  
											  }];
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

#pragma mark - Actions
- (IBAction)addShow {
	
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return shows.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ShowCell *cell = (ShowCell*)[tv dequeueReusableCellWithIdentifier:@"ShowCell"];
	
	SBShow *show = [shows objectAtIndex:indexPath.row];
	cell.showNameLabel.text = show.showName;
	
	[cell.posterImageView setImageWithURL:[[SickbeardAPIClient sharedClient] createUrlWithEndpoint:show.posterUrlPath] 
				   placeholderImage:nil
						  imageSize:CGSizeMake(55, 55)
							options:AFImageRequestRoundCorners
							  block:nil];	
	
	return cell;
}


@end
