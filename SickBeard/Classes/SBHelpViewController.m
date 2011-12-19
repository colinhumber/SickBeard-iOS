//
//  SBHelpViewController.m
//  SickBeard
//
//  Created by Colin Humber on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBHelpViewController.h"
#import <MaaSive/MaaSive.h>
#import "SBFaq.h"
#import "SBFaqCell.h"

@implementation SBHelpViewController

@synthesize questions;

#pragma mark - View lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = NSLocalizedString(@"FAQ", @"FAQ");
	self.enableEmptyView = NO;
	self.enableRefreshHeader = NO;

    [super viewDidLoad];

	[SVProgressHUD showWithStatus:@"Loading questions"];
	
	NSDictionary *query = [NSDictionary dictionaryWithObject:@"1" forKey:@"published.eql"];
	
	[SBFaq findRemoteWithQuery:query 
			   completionBlock:^(NSArray *objects, NSError *error) {
				   dispatch_async(dispatch_get_main_queue(), ^{
					   if (!error) {
						   [SVProgressHUD dismiss];
						   
						   self.questions = objects;
						   [self.tableView reloadData];
					   }
					   else {
						   NSLog(@"Error: %@", error);
					   }
				   });
			   }];
	
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
	cell.questionLabel.text = question.question;	
	cell.answerLabel.text = question.answer;
	
	CGRect questionFrame = cell.questionLabel.frame;
	CGRect answerFrame = cell.answerLabel.frame;
	
	CGSize questionSize = [question.question sizeWithFont:[UIFont boldSystemFontOfSize:13] 
										constrainedToSize:CGSizeMake(300, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	CGSize answerSize = [question.answer sizeWithFont:[UIFont systemFontOfSize:13] 
									constrainedToSize:CGSizeMake(300, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];

	questionFrame.size = CGSizeMake(300, questionSize.height);
	answerFrame.size = CGSizeMake(300, answerSize.height);
	
	cell.questionLabel.frame = questionFrame;
	cell.answerLabel.frame = answerFrame;
	
	return cell;
} 
	 
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	SBFaq *question = [self.questions objectAtIndex:indexPath.row];
	
	CGSize questionSize = [question.question sizeWithFont:[UIFont boldSystemFontOfSize:13] 
										constrainedToSize:CGSizeMake(300, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	CGSize answerSize = [question.answer sizeWithFont:[UIFont systemFontOfSize:13] 
									constrainedToSize:CGSizeMake(300, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	
	
	return questionSize.height + answerSize.height + 25;
}

@end
