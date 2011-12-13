//
//  SBEpisodeDetailsViewController.m
//  SickBeard
//
//  Created by Colin Humber on 9/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBEpisodeDetailsViewController.h"
#import "SBEpisode.h"
#import "SBShow.h"
#import "SickbeardAPIClient.h"
#import "PRPAlertView.h"
#import "NSDate+Utilities.h"

@implementation SBEpisodeDetailsViewController

@synthesize titleLabel;
@synthesize airDateLabel;
@synthesize seasonLabel;
@synthesize descriptionLabel;
@synthesize showPosterImageView;
@synthesize episode;

#pragma mark - View lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[TestFlight passCheckpoint:@"Viewed episode details"];
	
	self.title = @"Details";
	
	[self loadData];
	
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setAirDateLabel:nil];
    [self setSeasonLabel:nil];
    [self setDescriptionLabel:nil];
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
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							episode.show.tvdbID, @"tvdbid", 
							[NSNumber numberWithInt:episode.season], @"season",
							[NSNumber numberWithInt:episode.number], @"episode", nil];
	
	[SVProgressHUD showWithStatus:@"Loading episode info"];
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandEpisode 
									   parameters:params
										  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  episode.episodeDescription = [[JSON objectForKey:@"data"] objectForKey:@"description"];												  
											  }
											  else {
												  episode.episodeDescription = @"Unable to retrieve episode description";
											  }
											  
											  self.titleLabel.text = episode.name;
											  self.seasonLabel.text = [NSString stringWithFormat:@"Season %d, episode %d", episode.season, episode.number];
											  
											  [self.showPosterImageView setImageWithURL:[[SickbeardAPIClient sharedClient] bannerURLForTVDBID:episode.show.tvdbID]
																	   placeholderImage:nil];
											  
											  if (episode.airDate) {
												  if ([episode.airDate isToday]) {
													  self.airDateLabel.text = @"Airing today";
												  }
												  else if ([episode.airDate isLaterThanDate:[NSDate date]]) {
													  self.airDateLabel.text = [NSString stringWithFormat:@"Airing on %@", [episode.airDate displayString]];
												  }
												  else {
													  self.airDateLabel.text = [NSString stringWithFormat:@"Aired on %@", [episode.airDate displayString]];
												  }												  
											  }
											  else {
												  self.airDateLabel.text = @"Unknown air date";
											  }
											  
											  // 162
											  CGFloat currentFontSize = self.descriptionLabel.font.pointSize;
											  /*
											   while (titleSize.height > MAX_TITLE_SIZE.height) {
											   currentFontSize--;
											   titleSize = [_titleLabel.text sizeWithFont:[_titleLabel.font fontWithSize:currentFontSize]
											   constrainedToSize:CGSizeMake(MAX_TITLE_SIZE.width, CGFLOAT_MAX)
											   lineBreakMode:UILineBreakModeWordWrap];
											   }
											   */
											  CGRect frame = self.descriptionLabel.frame;
											  self.descriptionLabel.text = episode.episodeDescription;
											  CGSize size = [episode.episodeDescription sizeWithFont:self.descriptionLabel.font 
																				   constrainedToSize:CGSizeMake(frame.size.width, CGFLOAT_MAX)
																					   lineBreakMode:UILineBreakModeWordWrap];
											  while (size.height > self.descriptionLabel.frame.size.height) {
												  currentFontSize--;
												  size = [episode.episodeDescription sizeWithFont:[self.descriptionLabel.font fontWithSize:currentFontSize] 
																				constrainedToSize:CGSizeMake(frame.size.width, CGFLOAT_MAX)
																					lineBreakMode:UILineBreakModeWordWrap];
											  }
											  
											  self.descriptionLabel.font = [self.descriptionLabel.font fontWithSize:currentFontSize];
											  frame.size = size;
											  self.descriptionLabel.frame = frame;
											  
											  [SVProgressHUD dismiss];
										  }
										  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
											  [SVProgressHUD dismiss];
											  [PRPAlertView showWithTitle:@"Error retrieving episode" 
																  message:[NSString stringWithFormat:@"Could not retreive episode details \n%@", error.localizedDescription] 
															  buttonTitle:@"OK"];											  
										  }];
}

#pragma mark - Actions
- (IBAction)episodeAction:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" 
															 delegate:self 
													cancelButtonTitle:@"Cancel" 
											   destructiveButtonTitle:nil 
													 otherButtonTitles:@"Search", @"Set Status", nil];
	actionSheet.tag = 998;
	[actionSheet showInView:self.view];
}

- (void)searchForEpisode {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							episode.show.tvdbID, @"tvdbid", 
							[NSNumber numberWithInt:episode.season], @"season",
							[NSNumber numberWithInt:episode.number], @"episode", nil];

	[SVProgressHUD showWithStatus:@"Searching for episode"];

	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandEpisodeSearch 
									   parameters:params 
										  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  [SVProgressHUD dismissWithSuccess:@"Episode found and is downloading" afterDelay:2];
											  }
											  else {
												  [SVProgressHUD dismissWithError:[JSON objectForKey:@"message"] afterDelay:2];
											  }
										  }
										  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
											  [PRPAlertView showWithTitle:@"Error retrieving shows" 
																  message:[NSString stringWithFormat:@"Could not retreive shows \n%@", error.localizedDescription] 
															  buttonTitle:@"OK"];	
											  [SVProgressHUD dismiss];
										  }];
}

- (void)showEpisodeStatusActionSheet {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" 
															  delegate:self 
													 cancelButtonTitle:@"Cancel" 
												destructiveButtonTitle:nil 
													 otherButtonTitles:@"Wanted", @"Skipped", @"Archived", @"Ignored", nil];
	actionSheet.tag = 999;
	[actionSheet showInView:self.view];
}

- (void)performSetEpisodeStatus:(EpisodeStatus)status {
	NSString *statusString = [[SBEpisode episodeStatusAsString:status] lowercaseString];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							episode.show.tvdbID, @"tvdbid", 
							[NSNumber numberWithInt:episode.season], @"season",
							[NSNumber numberWithInt:episode.number], @"episode",
							statusString, @"status", nil];
	
	[SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Setting episode status to %@", statusString]];

	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandEpisodeSetStatus 
									   parameters:params 
										  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  [SVProgressHUD dismissWithSuccess:@"Status successfully set!" afterDelay:2];
											  }
											  else {
												  [SVProgressHUD dismissWithError:[JSON objectForKey:@"message"] afterDelay:2];
											  }
										  }
										  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
											  [PRPAlertView showWithTitle:@"Error retrieving shows" 
																  message:[NSString stringWithFormat:@"Could not retreive shows \n%@", error.localizedDescription] 
															  buttonTitle:@"OK"];	
											  [SVProgressHUD dismiss];
										  }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 998) {
		if (buttonIndex == 0) {
			[TestFlight passCheckpoint:@"Searched for episode"];
			[self searchForEpisode];
		}
		else if (buttonIndex == 1) {
			[self showEpisodeStatusActionSheet];
		}
	}
	else {
		if (buttonIndex < 4) {
			[TestFlight passCheckpoint:@"Set episode status"];
			[self performSetEpisodeStatus:buttonIndex];
		}
	}
}	

@end
