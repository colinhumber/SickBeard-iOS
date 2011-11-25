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
#import "ATMHud.h"
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
	self.title = @"Details";
		
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							episode.show.tvdbID, @"tvdbid", 
							[NSNumber numberWithInt:episode.season], @"season",
							[NSNumber numberWithInt:episode.number], @"episode", nil];
	
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
											  self.airDateLabel.text = episode.airDate ? [NSString stringWithFormat:@"Aired on %@", [episode.airDate displayString]] : @"Unknown Air Date";
											  self.seasonLabel.text = [NSString stringWithFormat:@"Season %d, episode %d", episode.season, episode.number];
											  self.descriptionLabel.text = episode.episodeDescription;
											  
											  [self.showPosterImageView setImageWithURL:[[SickbeardAPIClient sharedClient] posterURL:episode.show.tvdbID]
																	   placeholderImage:nil];
										  }
										  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
											  [PRPAlertView showWithTitle:@"Error retrieving episode" 
																  message:[NSString stringWithFormat:@"Could not retreive episode details \n%@", error.localizedDescription] 
															  buttonTitle:@"OK"];											  
										  }];
	
	
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

	[self.hud setCaption:@"Searching for episode..."];
	[self.hud setActivity:YES];
	[self.hud show];
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandEpisodeSearch 
									   parameters:params 
										  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  [self.hud setActivity:NO];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  [self.hud setCaption:@"Episode found and is downloading."];
												  [self.hud setImage:[UIImage imageNamed:@"19-check"]];
												  [self.hud update];
												  [self.hud hideAfter:2];
											  }
											  else {
												  [self.hud setCaption:[JSON objectForKey:@"message"]];
												  [self.hud update];
												  [self.hud hideAfter:2];
											  }
										  }
										  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
											  [PRPAlertView showWithTitle:@"Error retrieving shows" 
																  message:[NSString stringWithFormat:@"Could not retreive shows \n%@", error.localizedDescription] 
															  buttonTitle:@"OK"];	
										  }];
}

- (void)showEpisodeStatusActionSheet {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" 
															  delegate:self 
													 cancelButtonTitle:@"Cancel" 
												destructiveButtonTitle:nil 
													 otherButtonTitles:@"Wanted", @"Skipped", @"Archived", @"Ignored", nil];
	actionSheet.tag = 999;
	[actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)performSetEpisodeStatus:(EpisodeStatus)status {
	NSString *statusString = [SBEpisode episodeStatusAsString:status];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							episode.show.tvdbID, @"tvdbid", 
							[NSNumber numberWithInt:episode.season], @"season",
							[NSNumber numberWithInt:episode.number], @"episode",
							statusString, @"status", nil];
	
	[self.hud setCaption:[NSString stringWithFormat:@"Setting episode status to %@", statusString]];
	[self.hud setActivity:YES];
	[self.hud show];

	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandEpisodeSetStatus 
									   parameters:params 
										  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
																 
											  [self.hud setActivity:NO];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  [self.hud setCaption:@"Status successfully set!"];
												  [self.hud setImage:[UIImage imageNamed:@"19-check"]];
											  }
											  else {
												  [self.hud setCaption:[JSON objectForKey:@"message"]];
												  [self.hud setImage:[UIImage imageNamed:@"11-x"]];
											  }
												   
											  [self.hud update];
											  [self.hud hideAfter:2];
										  }
										  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
											  [PRPAlertView showWithTitle:@"Error retrieving shows" 
																  message:[NSString stringWithFormat:@"Could not retreive shows \n%@", error.localizedDescription] 
															  buttonTitle:@"OK"];	
										  }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 998) {
		if (buttonIndex == 0) {
			[self searchForEpisode];
		}
		else if (buttonIndex == 1) {
			[self showEpisodeStatusActionSheet];
		}
	}
	else {
		if (buttonIndex < 4) {
			[self performSetEpisodeStatus:buttonIndex];
		}
	}
}	

@end
