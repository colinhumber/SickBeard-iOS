//
//  SBBaseViewController.h
//  SickBeard
//
//  Created by Colin Humber on 11/3/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBDataLoader.h"
#import "SBNotificationManager.h"
#import "SVProgressHUD.h"
#import "SickbeardAPIClient.h"

@interface SBBaseViewController : UIViewController <SBDataLoader>

@property (nonatomic, strong) SickbeardAPIClient *apiClient;

- (void)refresh:(id)sender;

@end
