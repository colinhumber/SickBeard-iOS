//
//  SBAddShowViewController.h
//  SickBeard
//
//  Created by Colin Humber on 9/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBAddShowViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate> {
	NSArray *results;
	NSString *currentLanguage;
	BOOL isSearching;
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIPickerView *languagePickerView;
@property (nonatomic, retain) IBOutlet UITextField *showNameTextField;

@end
