//
//  SBEpisodeDetailsViewController.m
//  SickBeard
//
//  Created by Colin Humber on 9/1/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
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
#import <AFNetworking/UIImageView+AFNetworking.h>

#define kDefaultDescriptionFontSize 13;
#define kDefaultDescriptionFrame CGRectMake(20, 9, 280, 162)

@interface SBEpisodeDetailsViewController () <UIActionSheetDelegate> {
	BOOL _isTransitioning;
}

- (IBAction)swipeLeft:(id)sender;
- (IBAction)swipeRight:(id)sender;
- (void)updateHeaderView;

@property (nonatomic, strong) IBOutlet SBEpisodeDetailsHeaderView *currentHeaderView;
@property (nonatomic, strong) IBOutlet SBEpisodeDetailsHeaderView *nextHeaderView;
@property (nonatomic, strong) IBOutlet UIView *containerView;

@property (nonatomic, strong) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, strong) IBOutlet UIImageView *showPosterImageView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) IBOutlet SBSectionHeaderView *headerView;

@end

@implementation SBEpisodeDetailsViewController

#pragma mark - View lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[TestFlight passCheckpoint:@"Viewed episode details"];
	
	self.title = NSLocalizedString(@"Details", @"Details");

	__weak __typeof(&*self)weakSelf = self;
	NSURLRequest *bannerRequest = [NSURLRequest requestWithURL:[self.apiClient bannerURLForTVDBID:self.episode.show.tvdbID]];
	[self.showPosterImageView setImageWithURLRequest:bannerRequest
									placeholderImage:nil
											 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
												 CGSize size = CGSizeMake(340.0f, 63.0f);
												 UIGraphicsBeginImageContextWithOptions(size, YES, 0.0f);
												 [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
												 UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
												 UIGraphicsEndImageContext();
												 
												 weakSelf.showPosterImageView.image = newImage;
											 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
												 
											 }];
	
	UIInterpolatingMotionEffect *xMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	xMotionEffect.minimumRelativeValue = @(-10);
	xMotionEffect.maximumRelativeValue = @(10);
	
	UIInterpolatingMotionEffect *yMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	yMotionEffect.minimumRelativeValue = @(-5);
	yMotionEffect.maximumRelativeValue = @(5);

	UIMotionEffectGroup *motionGroup = [UIMotionEffectGroup new];
	motionGroup.motionEffects = @[xMotionEffect, yMotionEffect];
	
	[self.showPosterImageView addMotionEffect:motionGroup];
	
	self.headerView.sectionLabel.text = NSLocalizedString(@"Episode Summary", @"Episode Summary");
	
	[self updateHeaderView];
	[self loadData];
	
	if ([UIScreen mainScreen].bounds.size.height == 568) {
		self.descriptionTextView.height += 88;
	}
	
    [super viewDidLoad];
}

- (BOOL)shouldAutorotate {
	return NO;
}

#pragma mark - Loading
- (void)updateHeaderView {	
	self.currentHeaderView.titleLabel.text = self.episode.name;
	self.currentHeaderView.seasonLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Season %d, episode %d", @"Season %d, episode %d"), self.episode.season, self.episode.number];
		
	if (self.episode.airDate) {
		if ([self.episode.airDate isToday]) {
			self.currentHeaderView.airDateLabel.text = NSLocalizedString(@"Airing today", @"Airing today");
		}
		else if ([self.episode.airDate isLaterThanDate:[NSDate date]]) {
			self.currentHeaderView.airDateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Airing on %@", @"Airing on %@"), [self.episode.airDate displayString]];
		}
		else {
			self.currentHeaderView.airDateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Aired on %@", @"Aired on %@"), [self.episode.airDate displayString]];
		}												  
	}
	else {
		self.currentHeaderView.airDateLabel.text = NSLocalizedString(@"Unknown air date", @"Unknown air date");
	}
}

- (void)loadData {
	[UIView animateWithDuration:0.3 
					 animations:^{
						 self.descriptionTextView.alpha = 0;
					 }];
	
	NSDictionary *params = @{@"tvdbid": self.episode.show.tvdbID,
							@"season": @(self.episode.season),
							@"episode": @(self.episode.number)};

	[self.spinner startAnimating];
	
	[self.apiClient runCommand:SickBeardCommandEpisode
									   parameters:params
										  success:^(NSURLSessionDataTask *task, id JSON) {
											  NSString *result = JSON[@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  self.episode.episodeDescription = JSON[@"data"][@"description"];												  
											  }
											  else {
												  self.episode.episodeDescription = NSLocalizedString(@"Unable to retrieve episode description", @"Unable to retrieve episode description");
											  }
											  
											  [self.descriptionTextView flashScrollIndicators];
											  
											  self.descriptionTextView.text = self.episode.episodeDescription;

											  [UIView animateWithDuration:0.3
															   animations:^{
																   self.descriptionTextView.alpha = 1;
															   }];
											  
											  [self.spinner stopAnimating];
										  }
										  failure:^(NSURLSessionDataTask *task, NSError *error) {
											  [self.spinner stopAnimating];
											  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving episode", @"Error retrieving episode") 
																  message:[NSString stringWithFormat:NSLocalizedString(@"Could not retrieve episode details \n%@", @"Could not retrieve episode details \n%@"), error.localizedDescription] 
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
	
	id tmp = self.nextHeaderView;
	self.nextHeaderView = self.currentHeaderView;
	self.currentHeaderView = tmp;	
}

- (IBAction)swipeLeft:(id)sender {
	if (self.dataSource) {
		SBBaseEpisode *nextEpisode = [self.dataSource nextEpisode];

		if (!_isTransitioning && nextEpisode) {
			self.episode = nextEpisode;
			[self loadData];
			[self transitionToEpisodeFromDirection:kCATransitionFromRight];
			[self updateHeaderView];
		}
	}
}

- (IBAction)swipeRight:(id)sender {
	if (self.dataSource) {
		SBBaseEpisode *previousEpisode = [self.dataSource previousEpisode];

		if (!_isTransitioning && previousEpisode) {
			self.episode = previousEpisode;
			[self loadData];
			[self transitionToEpisodeFromDirection:kCATransitionFromLeft];
			[self updateHeaderView];
		}
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
	NSDictionary *params = @{@"tvdbid": self.episode.show.tvdbID, 
							@"season": @(self.episode.season),
							@"episode": @(self.episode.number)};

	[TSMessage showNotificationWithTitle:NSLocalizedString(@"Searching for episode", @"Searching for episode")
									type:TSMessageNotificationTypeMessage];

	[self.apiClient runCommand:SickBeardCommandEpisodeSearch
									   parameters:params 
										  success:^(NSURLSessionDataTask *task, id JSON) {
											  NSString *result = JSON[@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  [TSMessage showNotificationWithTitle:NSLocalizedString(@"Episode found and is downloading", @"Episode found and is downloading")
																				  type:TSMessageNotificationTypeSuccess];
											  }
											  else {
												  [TSMessage showNotificationWithTitle:JSON[@"message"]
																				  type:TSMessageNotificationTypeSuccess];
											  }
										  }
										  failure:^(NSURLSessionDataTask *task, NSError *error) {
											  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving shows", @"Error retrieving shows") 
																  message:[NSString stringWithFormat:@"Could not retrieve shows \n%@", error.localizedDescription] 
															  buttonTitle:NSLocalizedString(@"OK", @"OK")];
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
	
	NSDictionary *params = @{@"tvdbid": self.episode.show.tvdbID, 
							@"season": @(self.episode.season),
							@"episode": @(self.episode.number),
							@"status": statusString};
	
	[TSMessage showNotificationWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Setting episode status to %@", @"Setting episode status to %@"), statusString]
									type:TSMessageNotificationTypeMessage];
	
	[self.apiClient runCommand:SickBeardCommandEpisodeSetStatus
									   parameters:params 
										  success:^(NSURLSessionDataTask *task, id JSON) {
											  NSString *result = JSON[@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  [TSMessage showNotificationWithTitle:NSLocalizedString(@"Status successfully set!", @"Status successfully set!")
																				  type:TSMessageNotificationTypeSuccess];
											  }
											  else {
												  [TSMessage showNotificationWithTitle:JSON[@"message"]
																				  type:TSMessageNotificationTypeError];
											  }
										  }
										  failure:^(NSURLSessionDataTask *task, NSError *error) {
											  [PRPAlertView showWithTitle:NSLocalizedString(@"Error setting status", @"Error setting status") 
																  message:error.localizedDescription 
															  buttonTitle:NSLocalizedString(@"OK", @"OK")];	
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
