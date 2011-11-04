//
//  SBBaseViewController.h
//  SickBeard
//
//  Created by Colin Humber on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBHudViewController.h"
#import "SBDataLoader.h"

@interface SBBaseViewController : UIViewController <SBHudViewController, SBDataLoader>


@end
