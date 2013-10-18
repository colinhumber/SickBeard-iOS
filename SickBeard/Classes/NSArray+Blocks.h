//
//  NSArray+Blocks.h
//  Handy codebits
//
//  Created by Sijawusz Pur Rahnama on 15/11/09.
//  Copyleft 2009 Sijawusz Pur Rahnama. Some rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Blocks)

- (BOOL) all:(BOOL (^)(id obj))block;
- (BOOL) every:(BOOL (^)(id obj))block; /// @ref self::all()
- (BOOL) any:(BOOL (^)(id obj))block;
- (BOOL) some:(BOOL (^)(id obj))block; /// @ref self::any()

- (void) each:(void (^)(id obj))block;

- (NSArray *) sort:(NSComparisonResult (^)(id obj1, id obj2))block;
- (id) find:(BOOL (^)(id obj))block;
- (id) detect:(BOOL (^)(id obj))block; /// @ref self::find()
- (NSArray *) select:(BOOL (^)(id obj))block;
- (NSArray *) findAll:(BOOL (^)(id obj))block; /// @ref self::select()
- (NSArray *) filter:(BOOL (^)(id obj))block; /// @ref self::select()
- (NSArray *) reject:(BOOL (^)(id obj))block;
- (NSArray *) partition:(BOOL (^)(id obj))block;
- (NSArray *) map:(id (^)(id obj))block;
- (NSArray *) collect:(id (^)(id obj))block; /// @ref self::map()

@end