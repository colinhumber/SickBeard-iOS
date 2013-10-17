//
//  SBLogsViewController
//  SickBeard
//
//  Created by Colin Humber on 11/8/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBLogsViewController.h"
#import "SickbeardAPIClient.h"
#import "PRPAlertView.h"
#import "NSUserDefaults+SickBeard.h"
#import "SBLogCell.h"
#import "SVSegmentedControl.h"
#import "SVProgressHUD.h"

typedef enum {
	SBLogTypeDebug,
	SBLogTypeInfo,
	SBLogTypeWarning,
	SBLogTypeError
} SBLogType;

@interface SBLogsViewController ()
@property (nonatomic, strong) NSMutableArray *logs;
@property (nonatomic, assign) SBLogType logType;

- (IBAction)done:(id)sender;
@end

@implementation SBLogsViewController

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.logType = SBLogTypeDebug;
		
	[super viewDidLoad];

	SVSegmentedControl *logControl = [[SVSegmentedControl alloc] initWithSectionTitles:@[
										  NSLocalizedString(@"Debug", @"Debug"),
										  NSLocalizedString(@"Info", @"Info"),
										  NSLocalizedString(@"Warning", @"Warning"),
										  NSLocalizedString(@"Error", @"Error")]];
	
	logControl.font = [UIFont boldSystemFontOfSize:12];

	logControl.thumb.tintColor = RGBCOLOR(127, 92, 59);
	logControl.changeHandler = ^(NSUInteger newIndex) {
		[TestFlight passCheckpoint:@"Changed history type"];
		
		self.logType = newIndex;
		[self loadData];
	};
	
	UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:logControl];
	NSMutableArray *items = [self.toolbarItems mutableCopy];
	[items insertObject:barItem atIndex:0];
	self.toolbarItems = @[barItem];
		
	self.emptyView.emptyLabel.text = NSLocalizedString(@"No logs found", @"No logs found");
	
	[self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if ([self tableView:self.tableView numberOfRowsInSection:0] > 0) {
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Loading
- (void)loadData {
	[super loadData];
	
	[SVProgressHUD showWithStatus:NSLocalizedString(@"Loading logs", @"Loading logs")];

	NSString *logType;
	
	switch (_logType) {
		case SBLogTypeInfo:
			logType = @"info";
			break;
			
		case SBLogTypeWarning:
			logType = @"warning";
			break;
			
		case SBLogTypeError:
			logType = @"error";
			break;
			
		case SBLogTypeDebug:
		default:
			logType = @"debug";
			break;
	}
	
	[self.apiClient runCommand:SickBeardCommandViewLogs
									   parameters:@{ @"min_level" : logType }
										  success:^(NSURLSessionDataTask *task, id JSON) {
											  NSString *result = JSON[@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {												  
												  _logs = JSON[@"data"];
												  
												  if (_logs.count == 0) {
													  [self showEmptyView:YES animated:YES];
													  NSLog(@"No logs");
												  }
											  }
											  else {
												  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving logs", @"Error retrieving logs")
																	  message:JSON[@"message"] 
																  buttonTitle:NSLocalizedString(@"OK", @"OK")];
											  }
											  
											  [self finishDataLoad:nil];
											  [self.tableView reloadData];
										  }
										  failure:^(NSURLSessionDataTask *task, NSError *error) {
											  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving logs", @"Error retrieving logs") 
																  message:error.localizedDescription 
															  buttonTitle:NSLocalizedString(@"OK", @"OK")];			
											  
											  [self finishDataLoad:error];
										  }];
}

#pragma mark - Actions
- (IBAction)done:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)refresh:(id)sender {
	[TestFlight passCheckpoint:@"Refreshed logs"];
	
	[self loadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.logs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SBLogCell *cell = (SBLogCell *)[tv dequeueReusableCellWithIdentifier:@"SBLogCell"];
	cell.logLabel.text = self.logs[indexPath.row];

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *log = self.logs[indexPath.row];
	CGRect logSize = [log boundingRectWithSize:CGSizeMake(280, CGFLOAT_MAX)
									   options:NSStringDrawingUsesLineFragmentOrigin
									attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]}
									   context:nil];
//	CGSize logSize = [log sizeWithFont:[UIFont systemFontOfSize:12]
//					 constrainedToSize:CGSizeMake(280, CGFLOAT_MAX)];
    return logSize.size.height + 25;
}

@end
