//
//  MaaSManager.h
//  Copyright 2011 ELC Technologies. All rights reserved.

#import "ELCReachability.h"

@class MaaSCache;
@class MaaSModel;

/**
 * Defines the various error codes returned by the StatuMaaSit
 * web service.
 */

#define kMaaSServerError @"MaaSServerError"
#define kMaaSServerErrorCode 1
#define kMaaSCacheError @"MaaSCacheError"
#define kMaaSCacheErrorCode 2

/**
 * The MaaSManager is a singleton and is the main interface to MaaSive.  
 * It is responsible to setting up and maintaining all connections to the
 * server.
 *
 * In order to use MaaSive, the developer MUST set the secret key and
 * app id inside of this class to the corrisponding application on the
 * MaaSive server.
 *
 */

@interface MaaSManager : NSObject {
    
    NSString *_secretKey;
    NSString *_appId;

@private
	MaaSCache *_cache;
}

/**
 * The secret key used to access a given MaaSive applications
 */
@property (nonatomic, retain) NSString *secretKey;
/**
 * An application identifier to a specific MaaSive application.
 */
@property (nonatomic, retain) NSString *appId;

/**
 * This is a class method that returns the one and only instance of
 * the MaaSManager.  Upon first calling this method, a new MaaSManager
 * is instanciated and returned.
 *
 * @returns The MaaSManager singleton
 */

+ (MaaSManager*)sharedManager;

/** Synchronous Methods **/

/**
 * Invokes a given 3rd party service via the MaaSive Interface.  Developers 
 * are able to create services such as push, email, sms, and video rendering that
 * can interface with the MaaSive SDK.
 *
 * Once registered on the web, they can use the following call to invoke their service.
 * The parameters dictionary can contain any key-value's that are needed for their
 * service to function.
 *
 * An example parameters dictionary for a push service might look like this:
 *
 * {
 *       "device_token" = "1234567890987654321",
 *       "message"      = "Hello World!"
 * }
 *
 * Note: This method is synchronous
 *
 * @param service The name of the service you are calling (such as "elc-push")
 * @param command The command sent to that service. Note - all services are required to have commands
 * @param parameters The dictionary containing the configuration parameters to send to the service.
 * @param error An NSError pointer.  If the call fails, this will be non null
 * 
 * @returns an NSDictionary containing the response from the service that was called.
 */

- (NSDictionary *) callService:(NSString *) service 
                       command:(NSString *) command 
                    parameters:(NSDictionary *) parameters 
                         error:(NSError **) error;

/**
 * This method performs the same function as the callService synchronous method.  The
 * only difference is, it runs on a background thread and calls back to the passed
 * in completion block when it has finished executing.
 *
 * @param service The name of the service you are calling (such as "elc-push")
 * @param command The command sent to that service. Note - all services are required to have commands
 * @param parameters The dictionary containing the configuration parameters to send to the service.
 * @param block A block that returns an NSDictionary of results and an error in the event an error occurred.
 */

- (void) callService:(NSString *) service 
             command:(NSString *) command 
          parameters:(NSDictionary *) parameters
     completionBlock: (void (^)(NSDictionary *results, NSError *error)) block;

/**
 * This method will take all of the changes that have occured in your cache and send the changes up
 * to MaaSive. This include all instances in the cache that have been marked as new, updated or 
 * deleted.
 *
 * @param error an NSError object that will be non nil if the save fails
 */

- (BOOL)syncCache:(NSError**)error;

/**
 * This is the Asynchronous version of MaaSModel::syncCache:
 *
 * @param target the delegate class containing the needed callback method
 * @param selector a callback method of the form methodName:error this method should take
 * an array of MaaSModel subclass instances and an NSError. An example would be <br>
 * - (void) cacheDidSyncObjects:(NSArray *) objects error:(NSError *) error;
 */

- (void)syncCacheAsyncWithTarget:(id)target
                        selector:(SEL)selector;

/**
 * This is the block version of MaaSModel::syncCache:
 *
 * @param block the completion block to be executed upon completion of the sync
 */

- (void)syncCacheWithCompletionBlock:(void (^)(BOOL success, NSError *error))block;

@end