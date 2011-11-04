//
//  SBMainViewController.m
//  SickBeard
//
//  Created by Colin Humber on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBMainViewController.h"
#import "SBShowsViewController.h"
#import "SBEpisodesViewController.h"

@implementation SBMainViewController

@synthesize showsController;
@synthesize episodesController;
@synthesize currentController;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([SBShowsViewController class])]];
	[self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([SBEpisodesViewController class])]];
	
	self.currentController = [self.childViewControllers objectAtIndex:0];
	addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
															target:[self.childViewControllers objectAtIndex:0]
															action:@selector(addShow)];

	[self.view addSubview:self.currentController.view];
	self.navigationItem.rightBarButtonItem = addItem;
}

- (IBAction)viewModeChanged:(id)sender {
	UISegmentedControl *segment = sender;
	
	[self transitionFromViewController:self.currentController 
					  toViewController:[self.childViewControllers objectAtIndex:segment.selectedSegmentIndex] 
							  duration:0.3
							   options:UIViewAnimationOptionTransitionNone
							animations:nil 
							completion:^(BOOL finished) {
								if (finished) {
									[self.currentController didMoveToParentViewController:self];
								}
							}];

	self.currentController = [self.childViewControllers objectAtIndex:segment.selectedSegmentIndex];
	
	switch (segment.selectedSegmentIndex) {
		case 0:
			[self.navigationItem setRightBarButtonItem:addItem animated:YES];
			break;
			
		case 1:
			[self.navigationItem setRightBarButtonItem:nil animated:YES];
			break;
			
		default:
			break;
	}

	//self.view = self.currentController.view;
}

@end
