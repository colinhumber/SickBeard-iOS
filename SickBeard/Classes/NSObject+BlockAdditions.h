//
//  BlocksAdditions.h
//  PLBlocksPlayground
//
//  Created by Michael Ash on 8/9/09.
//

typedef void (^BasicBlock)(void);

void RunInBackground(BasicBlock block);
void RunOnMainThread(BOOL wait, BasicBlock block);
void RunOnThread(NSThread *thread, BOOL wait, BasicBlock block);
void RunAfterDelay(NSTimeInterval delay, BasicBlock block);
void WithAutoreleasePool(BasicBlock block);

void Parallelized(int count, void (^block)(int i));

@interface NSLock (BlocksAdditions)

- (void)whileLocked: (BasicBlock)block;

@end

@interface NSNotificationCenter (BlocksAdditions)

- (void)addObserverForName: (NSString *)name object: (id)object block: (void (^)(NSNotification *note))block;

@end

@interface NSURLConnection (BlocksAdditions)

+ (void)sendAsynchronousRequest: (NSURLRequest *)request completionBlock: (void (^)(NSData *data, NSURLResponse *response, NSError *error))block;

@end
