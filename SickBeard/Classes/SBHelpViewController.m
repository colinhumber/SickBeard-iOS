//
//  SBHelpViewController.m
//  SickBeard
//
//  Created by Colin Humber on 12/19/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBHelpViewController.h"
#import "SBFaq.h"
#import "SBFaqCell.h"
#import "SVProgressHUD.h"

@implementation SBHelpViewController

@synthesize questions;

#pragma mark - View lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = NSLocalizedString(@"FAQ", @"FAQ");
	self.enableEmptyView = YES;
	self.enableRefreshHeader = NO;
	
    [super viewDidLoad];

	self.emptyView.emptyLabel.text = NSLocalizedString(@"No FAQs found", @"No FAQs found");

	[self loadData];
	
	if (self.navigationController.viewControllers.count == 1) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done")
																				  style:UIBarButtonItemStyleDone
																				 target:self 
																				 action:@selector(done)];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions
- (void)loadData {
	[super loadData];
	
	[SVProgressHUD showWithStatus:@"Loading questions"];
	
	NSDictionary *query = [NSDictionary dictionaryWithObject:@"1" forKey:@"published.eql"];
	[self showEmptyView:YES animated:YES];

//	[SBFaq findRemoteWithQuery:query
//			   completionBlock:^(NSArray *objects, NSError *error) {
//				   dispatch_async(dispatch_get_main_queue(), ^{
//					   if (!error) {
//						   [SVProgressHUD dismiss];
//						   
//						   self.questions = objects;
//						   [self.tableView reloadData];
//						   
//						   if (self.questions.count == 0) {
//							   [self showEmptyView:YES animated:YES];
//						   }
//					   }
//					   else {
//						   NSLog(@"Error: %@", error);
//					   }
//				   });
//			   }];
}

- (void)done {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return questions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SBFaqCell *cell = (SBFaqCell*)[tv dequeueReusableCellWithIdentifier:@"FAQCell"];
	
	SBFaq *question = [questions objectAtIndex:indexPath.row];
	NSString *answerText = [question.answer stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
	cell.questionLabel.text = question.question;	
	cell.answerLabel.text = answerText;
	
	CGRect questionFrame = cell.questionLabel.frame;
	CGRect answerFrame = cell.answerLabel.frame;
	
	CGSize questionSize = [question.question sizeWithFont:[UIFont boldSystemFontOfSize:13] 
										constrainedToSize:CGSizeMake(300, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	CGSize answerSize = [answerText sizeWithFont:[UIFont systemFontOfSize:13] 
							   constrainedToSize:CGSizeMake(300, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];

	questionFrame.size = CGSizeMake(300, questionSize.height);
	answerFrame = CGRectMake(answerFrame.origin.x, questionFrame.origin.y + questionFrame.size.height + 3, 300, answerSize.height);
	
	cell.questionLabel.frame = questionFrame;
	cell.answerLabel.frame = answerFrame;
	
	return cell;
} 
	 
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	SBFaq *question = [self.questions objectAtIndex:indexPath.row];
	NSString *answerText = [question.answer stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
	
	CGSize questionSize = [question.question sizeWithFont:[UIFont boldSystemFontOfSize:13] 
										constrainedToSize:CGSizeMake(300, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	CGSize answerSize = [answerText	sizeWithFont:[UIFont systemFontOfSize:13] 
							   constrainedToSize:CGSizeMake(300, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	
	
	return questionSize.height + answerSize.height + 25;
}

@end
