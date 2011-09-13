//
//  SBServer+SickBeardAdditions.h
//  SickBeard
//
//  Created by Colin Humber on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBServer.h"

@interface SBServer (SickBeardAdditions)

- (BOOL)isValid;
- (NSString*)serviceEndpointPath;

@end
