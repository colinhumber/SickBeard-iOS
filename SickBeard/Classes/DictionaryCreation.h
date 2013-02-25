//
//  DictionaryCreation.h
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

@protocol DictionaryCreation <NSObject>

- (id)initWithDictionary:(NSDictionary*)dict;
+ (id)itemWithDictionary:(NSDictionary*)dict;

@end