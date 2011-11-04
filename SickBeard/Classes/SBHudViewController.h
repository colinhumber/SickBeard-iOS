//
//  SBHudViewController.h
//  SickBeard
//
//  Created by Colin Humber on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATMHud.h"

@protocol SBHudViewController <NSObject>

@property (nonatomic, strong) ATMHud *hud;

@end
