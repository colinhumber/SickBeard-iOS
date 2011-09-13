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

@property (nonatomic, retain) SBServer *server;

@property (retain, nonatomic) IBOutlet UITextField *nameTextField;
@property (retain, nonatomic) IBOutlet UITextField *hostTextField;
@property (retain, nonatomic) IBOutlet UITextField *portTextField;
@property (retain, nonatomic) IBOutlet UITextField *usernameTextField;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField;
@property (retain, nonatomic) IBOutlet UITextField *apiKeyTextField;
@property (retain, nonatomic) IBOutlet UISwitch *currentSwitch;

@end
