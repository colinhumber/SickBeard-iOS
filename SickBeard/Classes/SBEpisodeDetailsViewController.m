//
//  SBEpisodeDetailsViewController.m
//  SickBeard
//
//  Created by Colin Humber on 9/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SBEpisodeDetailsViewController.h"
#import "SBEpisode.h"
#import "SBShow.h"
#import "SickbeardAPIClient.h"
#import "PRPAlertView.h"
#import "NSDate+Utilities.h"
#import "SBEpisodeDetailsHeaderView.h"
#import "SBSectionHeaderView.h"
#import "SBCellBackground.h"

#define kDefaultDescriptionFontSize 13;
#define kDefaultDescriptionFrame CGRectMake(20, 9, 280, 162)

@interface SBEpisodeDetailsViewController ()
- (void)updateHeaderView;
@end

@implementation SBEpisodeDetailsViewController

@synthesize currentHeaderView;
@synthesize nextHeaderView;
@synthesize headerContainerView;
@synthesize containerView;
@synthesize descriptionLabel;
@synthesize showPosterImageView;
@synthesize spinner;
@synthesize episode;
@synthesize dataSource;
@synthesize headerView;
@synthesize episodeDescriptionBackground;

#pragma mark - View lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[TestFlight passCheckpoint:@"Viewed episode details"];
	
	self.title = NSLocalizedString(@"Details", @"Details");

	[self.showPosterImageView setImageWithURL:[[SickbeardAPIClient sharedClient] bannerURLForTVDBID:episode.show.tvdbID]
							 placeholderImage:nil];

	self.headerView.sectionLabel.text = NSLocalizedString(@"Episode Summary", @"Episode Summary");
	self.episodeDescriptionBackground.grouped = YES;
	
	[self updateHeaderView];
	[self loadData];
	
    [super viewDidLoad];
}


- (void)viewDidUnload {
	self.containerView = nil;
	self.currentHeaderView = nil;
	self.nextHeaderView = nil;
	self.descriptionLabel = nil;
	self.spinner = nil;
	self.showPosterImageView = nil;
	self.headerContainerView = nil;
	self.episodeDescriptionBackground = nil;
	self.headerView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Loading
- (void)updateHeaderView {	
	self.currentHeaderView.titleLabel.text = episode.name;
	self.currentHeaderView.seasonLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Season %d, episode %d", @"Season %d, episode %d"), episode.season, episode.number];
		
	if (episode.airDate) {
		if ([episode.airDate isToday]) {
			self.currentHeaderView.airDateLabel.text = NSLocalizedString(@"Airing today", @"Airing today");
		}
		else if ([episode.airDate isLaterThanDate:[NSDate date]]) {
			self.currentHeaderView.airDateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Airing on %@", @"Airing on %@"), [episode.airDate displayString]];
		}
		else {
			self.currentHeaderView.airDateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Aired on %@", @"Aired on %@"), [episode.airDate displayString]];
		}												  
	}
	else {
		self.currentHeaderView.airDateLabel.text = NSLocalizedString(@"Unknown air date", @"Unknown air date");
	}
}

- (void)loadData {
	[UIView animateWithDuration:0.3 
					 animations:^{
						 self.descriptionLabel.alpha = 0;
					 }];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							episode.show.tvdbID, @"tvdbid", 
							[NSNumber numberWithInt:episode.season], @"season",
							[NSNumber numberWithInt:episode.number], @"episode", nil];

	[self.spinner startAnimating];
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandEpisode 
									   parameters:params
										  success:^(NSURLRequest *request, NSURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  episode.episodeDescription = [[JSON objectForKey:@"data"] objectForKey:@"description"];												  
											  }
											  else {
												  episode.episodeDescription = NSLocalizedString(@"Unable to retrieve episode description", @"Unable to retrieve episode description");
											  }
											  
											  CGFloat currentFontSize = kDefaultDescriptionFontSize;
											  CGRect frame = kDefaultDescriptionFrame;
											  self.descriptionLabel.text = episode.episodeDescription;
											  CGSize size = [episode.episodeDescription sizeWithFont:[self.descriptionLabel.font fontWithSize:currentFontSize] 
																				   constrainedToSize:CGSizeMake(frame.size.width, CGFLOAT_MAX)
																					   lineBreakMode:UILineBreakModeWordWrap];
											  
											  while (size.height > frame.size.height) {
												  currentFontSize--;
												  size = [episode.episodeDescription sizeWithFont:[self.descriptionLabel.font fontWithSize:currentFontSize] 
																				constrainedToSize:CGSizeMake(frame.size.width, CGFLOAT_MAX)
																					lineBreakMode:UILineBreakModeWordWrap];
											  }
											  
											  self.descriptionLabel.font = [self.descriptionLabel.font fontWithSize:currentFontSize];
											  frame.size = size;
											  self.descriptionLabel.frame = frame;
											  
											  [UIView animateWithDuration:0.3 
															   animations:^{
																   self.descriptionLabel.alpha = 1;
															   }];
											  
											  [self.spinner stopAnimating];
										  }
										  failure:^(NSURLRequest *request, NSURLResponse *response, NSError *error, id JSON) {
											  [self.spinner stopAnimating];
											  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving episode", @"Error retrieving episode") 
																  message:[NSString stringWithFormat:NSLocalizedString(@"Could not retreive episode details \n%@", @"Could not retreive episode details \n%@"), error.localizedDescription] 
															  buttonTitle:NSLocalizedString(@"OK", @"OK")];											  
										  }];
}

#pragma mark - Gestures
- (void)transitionToEpisodeFromDirection:(NSString*)direction {
	_isTransitioning = YES;
		
	CATransition *transition = [CATransition animation];
	transition.duration = 0.2;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type = kCATransitionPush;
	transition.subtype = direction;
	transition.delegate = self;
	
	[self.containerView.layer addAnimation:transition forKey:nil];
	self.currentHeaderView.hidden = YES;
	self.nextHeaderView.hidden = NO;
	
	id tmp = nextHeaderView;
	self.nextHeaderView = self.currentHeaderView;
	self.currentHeaderView = tmp;	
}

- (IBAction)swipeLeft:(id)sender {
	SBEpisode *nextEpisode = [self.dataSource nextEpisode];
	
	if (!_isTransitioning && nextEpisode) {
		self.episode = nextEpisode;
		[self loadData];
		[self transitionToEpisodeFromDirection:kCATransitionFromRight];
		[self updateHeaderView];
	}
}

- (IBAction)swipeRight:(id)sender {
	SBEpisode *previousEpisode = [self.dataSource previousEpisode];

	if (!_isTransitioning && previousEpisode) {
		self.episode = previousEpisode;
		[self loadData];
		[self transitionToEpisodeFromDirection:kCATransitionFromLeft];
		[self updateHeaderView];
	}
}

- (void)animationDidStop:(CAAnimation*)theAnimation finished:(BOOL)flag {
    _isTransitioning = NO;
}

#pragma mark - Actions
- (IBAction)episodeAction:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" 
															 delegate:self 
													cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") 
											   destructiveButtonTitle:nil 
													 otherButtonTitles:NSLocalizedString(@"Search", @"Search"), NSLocalizedString(@"Set Status", @"Set Status"), nil];
	actionSheet.tag = 998;
	[actionSheet showInView:self.view];
}

- (void)searchForEpisode {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							episode.show.tvdbID, @"tvdbid", 
							[NSNumber numberWithInt:episode.season], @"season",
							[NSNumber numberWithInt:episode.number], @"episode", nil];

	[SVProgressHUD showWithStatus:NSLocalizedString(@"Searching for episode", @"Searching for episode")];

	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandEpisodeSearch 
									   parameters:params 
										  success:^(NSURLRequest *request, NSURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  [SVProgressHUD dismissWithSuccess:NSLocalizedString(@"Episode found and is downloading", @"Episode found and is downloading") afterDelay:2];
											  }
											  else {
												  [SVProgressHUD dismissWithError:[JSON objectForKey:@"message"] afterDelay:2];
											  }
										  }
										  failure:^(NSURLRequest *request, NSURLResponse *response, NSError *error, id JSON) {
											  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving shows", @"Error retrieving shows") 
																  message:[NSString stringWithFormat:@"Could not retreive shows \n%@", error.localizedDescription] 
															  buttonTitle:NSLocalizedString(@"OK", @"OK")];	
											  [SVProgressHUD dismiss];
										  }];
}

- (void)showEpisodeStatusActionSheet {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" 
															  delegate:self 
													 cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") 
												destructiveButtonTitle:nil 
													 otherButtonTitles:
															[SBEpisode episodeStatusAsString:EpisodeStatusWanted], 
															[SBEpisode episodeStatusAsString:EpisodeStatusSkipped], 
															[SBEpisode episodeStatusAsString:EpisodeStatusArchived], 
															[SBEpisode episodeStatusAsString:EpisodeStatusIgnored], nil];
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
	
	[SVProgressHUD showWithStatus:[NSString stringWithFormat:NSLocalizedString(@"Setting episode status to %@", @"Setting episode status to %@"), statusString]];

	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandEpisodeSetStatus 
									   parameters:params 
										  success:^(NSURLRequest *request, NSURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  [SVProgressHUD dismissWithSuccess:NSLocalizedString(@"Status successfully set!", @"Status successfully set!") afterDelay:2];
											  }
											  else {
												  [SVProgressHUD dismissWithError:[JSON objectForKey:@"message"] afterDelay:2];
											  }
										  }
										  failure:^(NSURLRequest *request, NSURLResponse *response, NSError *error, id JSON) {
											  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving shows", @"Error retrieving shows") 
																  message:[NSString stringWithFormat:@"Could not retreive shows \n%@", error.localizedDescription] 
															  buttonTitle:NSLocalizedString(@"OK", @"OK")];	
	
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
