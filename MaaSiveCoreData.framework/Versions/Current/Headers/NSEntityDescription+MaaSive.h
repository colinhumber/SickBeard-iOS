//
//  NSEntityDescription+MaaSive.h
//  StratusKit
//
//  Created by Collin Ruffenach on 6/27/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface NSEntityDescription (NSEntityDescription_MaaSive)

- (NSArray*)attributeKeys;
- (NSMutableString *)apiHash;
- (NSDictionary *)apiSchema;
-(NSDictionary*)toOneRelationships;
-(NSDictionary*)toManyRelationships;

@end
