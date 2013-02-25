//
//  SBHistory.h
//  SickBeard
//
//  Created by Colin Humber on 11/8/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DictionaryCreation.h"

@interface SBHistory : NSObject <DictionaryCreation>

@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, strong) NSString *quality;
@property (nonatomic, strong) NSString *showName;
@property (nonatomic) int season;
@property (nonatomic) int episode;
@property (nonatomic, strong) NSString *tvdbID;

@end
