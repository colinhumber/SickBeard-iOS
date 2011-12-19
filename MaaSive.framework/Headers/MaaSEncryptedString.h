//
//  MaaSEncryptedString.h
//  Copyright 2011 ELC Technologies. All rights reserved.

#import <Foundation/Foundation.h>

/**
 * This is a subclass of NSString.  It is used to create
 * encrypted strings on the web for use in things like passwords.
 */

@interface MaaSEncryptedString : NSString {
 
    NSString *_backingStore;
}

+(id)encryptedStringWithString:(NSString *)string;
-(id)initWithString:(NSString*)string;

@end
