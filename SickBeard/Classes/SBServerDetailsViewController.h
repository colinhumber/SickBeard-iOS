//
//  SBServerDetailsViewController.h
//  SickBeard
//
//  Created by Colin Humber on 8/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATMHudDelegate.h"

@class SBServer;

@interface SBServerDetailsViewController : UITableViewController <UITextFieldDelegate, ATMHudDelegate> {
	UITextField *currentResponder;
	BOOL isHudShowing;
}

@property (nonatomic, strong) SBServer *server;

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *hostTextField;
@property (strong, nonatomic) IBOutlet UITextField *portTextField;
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *apiKeyTextField;

@end
