//
//  SBAddShowViewController.h
//  SickBeard
//
//  Created by Colin Humber on 9/7/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBAddShowDelegate.h"
#import "SBBaseViewController.h"

@interface SBAddShowViewController : SBBaseViewController

@property (nonatomic, weak) id<SBAddShowDelegate> delegate;

@end
