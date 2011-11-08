//
//  SBRootDirectory.h
//  SickBeard
//
//  Created by Colin Humber on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DictionaryCreation.h"

@interface SBRootDirectory : NSObject <DictionaryCreation, NSCoding>

@property (nonatomic) BOOL isDefault;
@property (nonatomic, strong) NSString *path;
@property (nonatomic) BOOL isValid;

@end
