//
//  SBBacklogViewController.h
//  SickBeard
//
//  Created by Colin Humber on 11/8/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBBaseTableViewController.h"

@interface SBBacklogViewController : SBBaseTableViewController

@property (nonatomic, strong) NSArray *shows;

- (IBAction)done:(id)sender;

@end
