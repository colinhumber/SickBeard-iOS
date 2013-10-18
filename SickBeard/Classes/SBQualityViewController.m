//
//  SBQualityViewController.m
//  SickBeard
//
//  Created by Colin Humber on 9/8/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBQualityViewController.h"

@implementation SBQualityViewController

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
	
	if (self.qualityType == QualityTypeInitial) {
		qualities = [[SBGlobal initialQualities] allKeys];
	}
	else if (self.qualityType == QualityTypeArchive) {
		qualities = [[SBGlobal archiveQualities] allKeys];	
	}
}

- (BOOL)shouldAutorotate {
	return NO;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QualityCell"];
    
	NSString *quality = qualities[indexPath.row];
	
	cell.textLabel.text = quality;
	
	if ([self.currentQuality containsObject:quality]) {
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
		
	[self.delegate qualityViewController:self didSelectQualities:self.currentQuality];
}

@end
