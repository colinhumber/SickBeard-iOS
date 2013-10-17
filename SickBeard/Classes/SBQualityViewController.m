//
//  SBQualityViewController.m
//  SickBeard
//
//  Created by Colin Humber on 9/8/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBQualityViewController.h"
#import "SBCellBackground.h"

@implementation SBQualityViewController

@synthesize delegate;
@synthesize qualityType;
@synthesize currentQuality;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
	self.delegate = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];

	if (qualityType == QualityTypeInitial) {
		qualities = [[SBGlobal initialQualities] allKeys];
	}
	else if (qualityType == QualityTypeArchive) {
		qualities = [[SBGlobal archiveQualities] allKeys];	
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return qualities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QualityCell"];
    
	SBCellBackground *backgroundView = [[SBCellBackground alloc] init];
	backgroundView.grouped = YES;
	backgroundView.applyShadow = NO;
	
	SBCellBackground *selectedBackgroundView = [[SBCellBackground alloc] init];
	selectedBackgroundView.grouped = YES;
	selectedBackgroundView.applyShadow = NO;
	selectedBackgroundView.selected = YES;
	
	if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
		backgroundView.lastCell = YES;
		backgroundView.applyShadow = YES;
		selectedBackgroundView.lastCell = YES;
		selectedBackgroundView.applyShadow = YES;
	}
	
	cell.backgroundView = backgroundView;
	cell.selectedBackgroundView = selectedBackgroundView;
	
	NSString *quality = qualities[indexPath.row];
	
	cell.textLabel.text = quality;
	
	if ([currentQuality containsObject:quality]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		
	NSString *quality = qualities[indexPath.row];
	
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.currentQuality addObject:quality];
    }
	else {
		cell.accessoryType = UITableViewCellAccessoryNone;
		[self.currentQuality removeObject:quality];
	}
		
	[self.delegate qualityViewController:self didSelectQualities:currentQuality];
}

@end
