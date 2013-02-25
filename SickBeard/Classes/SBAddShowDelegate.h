//
//  SBAddShowDelegate.h
//  SickBeard
//
//  Created by Colin Humber on 12/2/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SBAddShowDelegate <NSObject>

- (void)didAddShow;
- (void)didCancelAddShow;

@end
