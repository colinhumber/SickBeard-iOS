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
#import "SVSegmentedControl.h"
#import "SBBaseViewController.h"

@implementation SBMainViewController

@synthesize currentController;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	SBShowsViewController *showVc = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([SBShowsViewController class])];
	SBEpisodesViewController *episodesVc = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([SBEpisodesViewController class])];

	[self addChildViewController:showVc];
	[showVc didMoveToParentViewController:self];
	
	[self addChildViewController:episodesVc];
	[episodesVc didMoveToParentViewController:self];
		
	self.currentController = [self.childViewControllers objectAtIndex:0];
	addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
															target:[self.childViewControllers objectAtIndex:0]
															action:@selector(addShow)];

	[self.view addSubview:self.currentController.view];
	self.navigationItem.rightBarButtonItem = addItem;
	self.navigationItem.leftBarButtonItem = self.currentController.editButtonItem;
	
	self.title = self.currentController.title;
	
	SVSegmentedControl *navControl = [[SVSegmentedControl alloc] initWithSectionTitles:
									  [NSArray arrayWithObjects:NSLocalizedString(@"Shows", @"Shows"), NSLocalizedString(@"Episodes", @"Episodes"), nil]];
	navControl.thumb.tintColor = RGBCOLOR(127, 92, 59);
	[navControl addTarget:self action:@selector(viewModeChanged:) forControlEvents:UIControlEventValueChanged];
	self.navigationItem.titleView = navControl;
}

- (IBAction)refresh:(id)sender {
	[self.currentController refresh:sender];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[SVProgressHUD dismiss];
}

- (IBAction)viewModeChanged:(id)sender {
	SVSegmentedControl *segment = sender;
	
	SBBaseViewController *destinationController = [self.childViewControllers objectAtIndex:segment.selectedIndex];
	if (self.currentController == destinationController){
		return;
	}
		
	[self transitionFromViewController:self.currentController 
					  toViewController:destinationController 
							  duration:0
							   options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionTransitionNone
							animations:nil 
							completion:nil];

	self.currentController = destinationController;
	self.title = self.currentController.title;

	switch (segment.selectedIndex) {
		case 0:
			[self.navigationItem setLeftBarButtonItem:self.currentController.editButtonItem animated:YES];
			[self.navigationItem setRightBarButtonItem:addItem animated:YES];
			break;
			
		case 1:
			[self.navigationItem setLeftBarButtonItem:nil animated:YES];
			[self.navigationItem setRightBarButtonItem:nil animated:YES];
			break;
			
		default:
			break;
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	self.navigationItem.rightBarButtonItem.enabled = !editing;
}



@end
