//
//  NSArray+Blocks.m
//  Handy codebits
//
//  Created by Sijawusz Pur Rahnama on 15/11/09.
//  Copyleft 2009 Sijawusz Pur Rahnama. Some rights reserved.
//

#import "NSArray+Blocks.h"

@implementation NSArray (Blocks)

- (BOOL) all:(BOOL (^)(id obj))block {
    BOOL truth = YES;
    for (id obj in self) {
        truth = truth && block(obj);
    }
    return truth;
}

- (BOOL) every:(BOOL (^)(id obj))block {
    return [self all:block];
}

- (BOOL) any:(BOOL (^)(id obj))block {
    BOOL truth = NO;
    for (id obj in self) {
        truth = truth || block(obj);
    }
    return truth;
}

- (BOOL) some:(BOOL (^)(id obj))block {
    return [self any:block];
}

- (void) each:(void (^)(id obj))block {
    for (id obj in self) {
        block(obj);
    }
}

- (NSArray *) sort:(NSComparator)block {
    return [self sortedArrayUsingComparator:block];
}

- (id) find:(BOOL (^)(id obj))block {
    for (id obj in self) {
        if (block(obj)) return obj;
    }
    return nil;
}

- (id) detect:(BOOL (^)(id obj))block {
    return [self find:block];
}

- (NSArray *) select:(BOOL (^)(id obj))block {
    NSMutableArray *new = [NSMutableArray array];
    for (id obj in self) {
        if (block(obj)) [new addObject:obj];
    }
    return new;
}

- (NSArray *) findAll:(BOOL (^)(id obj))block {
    return [self select:block];
}

- (NSArray *) filter:(BOOL (^)(id obj))block {
    return [self select:block];
}

- (NSArray *) reject:(BOOL (^)(id obj))block {
    NSMutableArray *new = [NSMutableArray array];
    for (id obj in self) {
        if (!block(obj)) [new addObject:obj];
    }
    return new;
}

- (NSArray *) partition:(BOOL (^)(id obj))block {
    NSMutableArray *ayes = [NSMutableArray array];
    NSMutableArray *noes = [NSMutableArray array];
    for (id obj in self) {
        if (block(obj)) {
            [ayes addObject:obj];
        } else {
            [noes addObject:obj];
        }
    }
    return @[ayes, noes];
}

- (NSArray *) map:(id (^)(id obj))block {
    NSMutableArray *new = [NSMutableArray arrayWithCapacity:[self count]];
    for (id obj in self) {
        id newObj = block(obj);
        [new addObject:newObj ? newObj : [NSNull null]];
    }
    return new;
}

- (NSArray *) collect:(id (^)(id obj))block {
    return [self map:block];
}

@end