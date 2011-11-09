//
//  NSString+Base64.h
//  SickBeard
//
//  Created by Colin Humber on 11/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Base64)

- (NSString *)base64Encode;
- (NSString *)base64Decode;

@end
