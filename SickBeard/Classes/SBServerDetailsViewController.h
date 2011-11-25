//
//  SBServerDetailsViewController.h
//  SickBeard
//
//  Created by Colin Humber on 8/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBBaseTableViewController.h"

@class SBServer;

@interface SBServerDetailsViewController : SBBaseTableViewController <UITextFieldDelegate> {
	UITextField *currentResponder;
	
	struct {
		unsigned int didCancel:1;
		unsigned int initialSetup:1;
	} _flags;
}

@property (nonatomic, strong) SBServer *server;

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *hostTextField;
@property (strong, nonatomic) IBOutlet UITextField *portTextField;
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *apiKeyTextField;

@end
