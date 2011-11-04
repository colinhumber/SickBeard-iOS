/*
 Copyright (c) 2009 Remy Demarest
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */

#import "NSTimer+BlockAdditions.h"

typedef void (^PSYTimerBlock)(NSTimer *);

#define SELF_EXECUTING 1

#if defined(SELF_EXECUTING) && SELF_EXECUTING

@interface NSTimer (PSYBlockTimer_private)
+ (void)PSYBlockTimer_executeBlockWithTimer:(NSTimer *)timer;
@end


@implementation NSTimer (PSYBlockTimer)
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats usingBlock:(void (^)(NSTimer *timer))fireBlock
{
    return [self scheduledTimerWithTimeInterval:seconds target:self selector:@selector(PSYBlockTimer_executeBlockWithTimer:) userInfo:[fireBlock copy] repeats:repeats];
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats usingBlock:(void (^)(NSTimer *timer))fireBlock
{
    return [self timerWithTimeInterval:seconds target:self selector:@selector(PSYBlockTimer_executeBlockWithTimer:) userInfo:[fireBlock copy] repeats:repeats];
}
@end


@implementation NSTimer (PSYBlockTimer_private)
+ (void)PSYBlockTimer_executeBlockWithTimer:(NSTimer *)timer
{
    PSYTimerBlock block = [timer userInfo];
    block(timer);
}
@end

#else

// Private helper class
__attribute__((visibility("hidden")))
@interface _PSYBlockTimer : NSObject { PSYTimerBlock block; }
+ (id)blockTimer;
@property(copy) PSYTimerBlock block;
- (void)executeBlockWithTimer:(NSTimer *)timer;
@end

@implementation NSTimer (PSYBlockTimer)
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats usingBlock:(void (^)(NSTimer *timer))fireBlock
{
    _PSYBlockTimer *blkTimer = [_PSYBlockTimer blockTimer];
    [blkTimer setBlock:fireBlock];
    return [self scheduledTimerWithTimeInterval:seconds target:blkTimer selector:@selector(executeBlockWithTimer:) userInfo:nil repeats:repeats];
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats usingBlock:(void (^)(NSTimer *timer))fireBlock
{
    _PSYBlockTimer *blkTimer = [_PSYBlockTimer blockTimer];
    [blkTimer setBlock:fireBlock];
    return [self timerWithTimeInterval:seconds target:blkTimer selector:@selector(executeBlockWithTimer:) userInfo:nil repeats:repeats];
}
@end

@implementation _PSYBlockTimer
@synthesize block;

+ (id)blockTimer { return [[[self alloc] init] autorelease]; }
- (void)executeBlockWithTimer:(NSTimer *)timer
{
    block(timer);
}
- (void)dealloc
{
    [block release];
    [super dealloc];
}
@end

#endif