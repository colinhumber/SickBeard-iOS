//
//  SBDataLoader.h
//  SickBeard
//
//  Created by Colin Humber on 11/3/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SBDataLoader <NSObject>

- (void)loadData;
- (void)finishDataLoad:(NSError*)error;

@property (nonatomic) BOOL isDataLoading;
@property (nonatomic, strong) NSDate *loadDate;

@end
