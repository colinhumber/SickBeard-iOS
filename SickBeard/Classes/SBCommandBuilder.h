//
//  SBCommandBuilder.h
//  SickBeard
//
//  Created by Colin Humber on 8/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBServer;

@interface SBCommandBuilder : NSObject

+ (NSString*)URLForCommand:(SickBeardCommand)command server:(SBServer*)server params:(NSDictionary*)params;

@end

