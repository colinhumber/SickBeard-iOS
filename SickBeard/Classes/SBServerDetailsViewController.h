//
//  SBServerDetailsViewController.h
//  SickBeard
//
//  Created by Colin Humber on 8/29/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBBaseTableViewController.h"

@class SBServer;

@interface SBServerDetailsViewController : UITableViewController <UITextFieldDelegate> {
	UITextField *currentResponder;
	
	struct {
		unsigned int didCancel:1;
		unsigned int initialSetup:1;
	} _flags;
}

@property (nonatomic, strong) SBServer *server;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *hostTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UITextField *pathTextField;
@property (weak, nonatomic) IBOutlet UISwitch *sslSwitch;
@property (weak, nonatomic) IBOutlet UITextField *apiKeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end
