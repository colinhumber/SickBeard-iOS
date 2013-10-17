//
//  SBMainViewController.m
//  SickBeard
//
//  Created by Colin Humber on 11/3/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBMainViewController.h"
#import "SBShowsViewController.h"
#import "SBEpisodesViewController.h"
#import "SVSegmentedControl.h"
#import "SBBaseViewController.h"

@interface SBMainViewController ()
@property (nonatomic, strong) UIBarButtonItem *addItem;
@end

@implementation SBMainViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	[self.currentController prepareForSegue:segue sender:sender];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	SBShowsViewController *showVc = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([SBShowsViewController class])];
	SBEpisodesViewController *episodesVc = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([SBEpisodesViewController class])];
	
	[self addChildViewController:showVc];
	[showVc didMoveToParentViewController:self];
	
	[self addChildViewController:episodesVc];
	[episodesVc didMoveToParentViewController:self];
		
	self.currentController = (self.childViewControllers)[0];
	self.addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																 target:showVc
																 action:@selector(addShow)];

	[self.view addSubview:self.currentController.view];
	self.navigationItem.rightBarButtonItem = self.addItem;
	self.navigationItem.leftBarButtonItem = self.currentController.editButtonItem;
	
	self.title = self.currentController.title;
	
	SVSegmentedControl *navControl = [[SVSegmentedControl alloc] initWithSectionTitles:
									  @[NSLocalizedString(@"Shows", @"Shows"), NSLocalizedString(@"Episodes", @"Episodes")]];
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
	
	SBBaseViewController *destinationController = (self.childViewControllers)[segment.selectedIndex];
	if (self.currentController == destinationController){
		return;
	}
	
	destinationController.view.frame = self.view.bounds;
	
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
			[self.navigationItem setRightBarButtonItem:self.addItem animated:YES];
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
