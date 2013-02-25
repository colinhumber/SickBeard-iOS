//
//  SBCommandBuilder.h
//  SickBeard
//
//  Created by Colin Humber on 8/26/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBGlobal.h"

@class SBServer;

@interface SBCommandBuilder : NSObject

+ (NSString *)URLForCommands:(NSArray *)commands server:(SBServer *)server params:(NSDictionary *)params;
+ (NSString *)URLForCommand:(SickBeardCommand)command server:(SBServer *)server params:(NSDictionary *)params;

@end

