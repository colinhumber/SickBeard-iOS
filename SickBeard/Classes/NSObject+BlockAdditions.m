//
//  BlocksAdditions.m
//  PLBlocksPlayground
//
//  Created by Michael Ash on 8/9/09.
//

#import "NSObject+BlockAdditions.h"


@implementation NSObject (BlocksAdditions)

- (void)my_callBlock
{
    void (^block)(void) = (id)self;
    block();
}

- (void)my_callBlockWithObject: (id)obj
{
    void (^block)(id obj) = (id)self;
    block(obj);
}

@end

void RunInBackground(BasicBlock block)
{
    [NSThread detachNewThreadSelector: @selector(my_callBlock) toTarget: [block copy] withObject: nil];
}

void RunOnMainThread(BOOL wait, BasicBlock block)
{
    [[block copy] performSelectorOnMainThread: @selector(my_callBlock) withObject: nil waitUntilDone: wait];
}

void RunOnThread(NSThread *thread, BOOL wait, BasicBlock block)
{
    [[block copy] performSelector: @selector(my_callBlock) onThread: thread withObject: nil waitUntilDone: wait];
}

void RunAfterDelay(NSTimeInterval delay, BasicBlock block)
{
    [[block copy] performSelector: @selector(my_callBlock) withObject: nil afterDelay: delay];
}

void WithAutoreleasePool(BasicBlock block)
{
    @autoreleasepool {
        block();
    }
}

void Parallelized(int count, void (^block)(int i))
{
    for(int i = 0; i < count; i++)
        RunInBackground(^{ block(i); });
}

@implementation NSLock (BlocksAdditions)

- (void)whileLocked: (BasicBlock)block
{
    [self lock];
    @try
    {
        block();
    }
    @finally
    {
        [self unlock];
    }
}

@end

@implementation NSNotificationCenter (BlocksAdditions)

- (void)addObserverForName: (NSString *)name object: (id)object block: (void (^)(NSNotification *note))block
{
    [self addObserver: [block copy] selector: @selector(my_callBlockWithObject:) name: name object: object];
}

@end

@implementation NSURLConnection (BlocksAdditions)

+ (void)sendAsynchronousRequest: (NSURLRequest *)request completionBlock: (void (^)(NSData *data, NSURLResponse *response, NSError *error))block
{
    NSThread *originalThread = [NSThread currentThread];
    
    RunInBackground(^{
        WithAutoreleasePool(^{
            NSURLResponse *response = nil;
            NSError *error = nil;
            NSData *data = [self sendSynchronousRequest: request returningResponse: &response error: &error];
            RunOnThread(originalThread, NO, ^{ block(data, response, error); });
        });
    });
}

@end
