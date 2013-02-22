//
//  SBBaseViewController.h
//  SickBeard
//
//  Created by Colin Humber on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBDataLoader.h"
#import "SBNotificationManager.h"
#import "SVProgressHUD.h"

@interface SBBaseViewController : UIViewController <SBDataLoader>

- (void)refresh:(id)sender;

@end
