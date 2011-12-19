//
//  MaaSModel.h
//  Copyright 2011 ELC Technologies. All rights reserved.

#import <Foundation/Foundation.h>

/**
 * Every model that needs to be syncronized with the MaaSive web service
 * MUST extend this class. It provides all of the helper methods that facilitate
 * the web interface.
 *
 * We provide 3 difference architectures for calling the web facing methods.
 * They are:
 * <ul>
 *  <li>Synchronous</li>
 *  <li>Asynchronous With Callbacks</li>
 *  <li>Blocks</li>
 * </ul>
 *
 * Each of these architectures are discussed below with their associated methods.
 */

typedef enum { 
    MaaSModelCollisionTypeSaveRemoteConflict,
    MaaSModelCollisionTypeUpdateCacheConflict,
    MaaSModelCollisionTypeRemoveFromCacheConflict
} MaaSModelCollisionType;

typedef id (^MaaSModelCollisionHandlerBlock)(id remoteObject, id cachedObject, MaaSModelCollisionType collisionType);

@interface MaaSModel : NSObject {
    
    NSString *_id;
    NSDate *_created_at;
    NSDate *_updated_at;
    bool _locallyModified;
}

// Defaults

/** A unique ID given to all MaaSModels once saved **/
@property(nonatomic, retain) NSString *_id;

/** The date that the model was created **/
@property(nonatomic, retain) NSDate *created_at;

/** The last time this model was updated **/
@property(nonatomic, retain) NSDate *updated_at;

/** Flag for modification in cache not syned to MaaSive **/
@property(nonatomic, assign) bool locallyModified;

#pragma mark - Collision Block Setter

+ (MaaSModelCollisionHandlerBlock)collisionHandlerBlock;
+ (void)setCollisionHandlerBlock:(MaaSModelCollisionHandlerBlock)aStartedBlock;

#pragma mark - MaaSive Save Methods

/**
 * Synchronizes the MaaSModel with the web.  If this is a new model (ie its _id property is nil),
 * it will create a new record on the server, otherwise it will perform an update.  Call this
 * method anytime you want to create or update your MaaSModel objects.
 *
 * @param error an NSError pointer that will be non nil if there is an error
 * @returns a boolean that is YES upon success and NO on failure
 */

- (BOOL)saveRemote:(NSError **)error;

/**
 * Synchronizes the MaaSModel with the web.  If this is a new model, it will create 
 * a new record on the server, otherwise it will perform an update.  Call this
 * method anytime you want to create or update your MaaSModel objects.
 *
 * @param error an NSError pointer that will be non nil if there is an error
 * @param cacheResults an BOOL that indicates whether you would like to write this data to your cache upon success
 * @returns a boolean that is YES upon success and NO on failure
 */

- (BOOL)saveRemote:(NSError **)error
	  cacheResults:(BOOL)cacheResults;

/**
 * This is the Asynchronous version of MaaSModel::saveRemote: when it completes,
 * it will call the passed in selector of the passed in target with the MaaSModel subclass 
 * that was just saved.
 *
 * If the request fails, it will pass along a non nil value for the error
 *
 * If the request fails, it will call the MaaSModelDelegate::MaaSModel:didFailWithError: method
 * with the error.
 *
 * @param target the delegate class containing the needed callback method
 * @param selector a callback method of the form methodName:error this method should take
 * a MaaSModel subclass and an NSError.  An example would be <br>
 * - (void) saveRemoteAsyncWithTarget:(User *) user error:(NSError *) error;
 */

- (void) saveRemoteAsyncWithTarget:(id)target
						  selector:(SEL)selector;

/**
 * This is the Asynchronous version of MaaSModel::saveRemote: when it completes,
 * it will call the passed in selector of the passed in target with the MaaSModel subclass 
 * that was just saved.
 *
 * If the request fails, it will pass along a non nil value for the error
 *
 * If the request fails, it will call the MaaSModelDelegate::MaaSModel:didFailWithError: method
 * with the error.
 *
 * @param target the delegate class containing the needed callback method
 * @param selector a callback method of the form methodName:error this method should take
 * @param cacheResults an BOOL that indicates whether you would like to write this data to your cache upon success
 * a MaaSModel subclass and an NSError.  An example would be <br>
 * - (void) saveRemoteAsyncWithTarget:(User *) user error:(NSError *) error;
 */

- (void) saveRemoteAsyncWithTarget:(id)target
						  selector:(SEL)selector
					  cacheResults:(BOOL)cacheResults;

/**
 * Block version of MaaSModel::saveRemote:
 *
 * This method will asynchronously (using GCD) save an MaaSModel to the web
 * When it completes, it will run the passed in block with the result of the save.
 *
 * @param block the return block.  
 *  The block takes 2 arguments
 *   - saved - a bool that is true on success, and false on failure
 *   - error - an NSError object that will be non nil if the request fails
 */

- (void)saveRemoteWithBlock:(void (^)(BOOL saved, NSError *error))block;

/**
 * Block version of MaaSModel::saveRemote:
 *
 * This method will asynchronously (using GCD) save an MaaSModel to the web
 * When it completes, it will run the passed in block with the result of the save.
 *
 * @param block the return block.  
 * @param cacheResults an BOOL that indicates whether you would like to write this data to your cache upon success
 *  The block takes 2 arguments
 *   - saved - a bool that is true on success, and false on failure
 *   - error - an NSError object that will be non nil if the request fails
 */

- (void)saveRemoteWithCachedResults:(BOOL)cacheResults
                    completionBlock:(void (^)(BOOL saved, NSError *error))block;

#pragma mark - MaaSive Cache Save Methods

/**
 * Saves the MaaSModel with the cache.  Call this method anytime
 * you want to create or update your MaaSModel objects in the cache.
 *
 * @param error an NSError pointer that will be non nil if there is an error
 * @returns a boolean that is YES upon success and NO on failure
 */

- (BOOL)saveToCache:(NSError **)error;

/**
 * This is the Asynchronous version of MaaSModel::saveToCache: when it completes,
 * it will call the passed in selector of the passed in target with the MaaSModel subclass 
 * that was just saved.
 *
 * If the request fails, it will pass along a non nil value for the error
 *
 * If the request fails, it will call the MaaSModelDelegate::MaaSModel:didFailWithError: method
 * with the error.
 *
 * @param target the delegate class containing the needed callback method
 * @param selector a callback method of the form methodName:error this method should take
 * a MaaSModel subclass and an NSError.  An example would be <br>
 * - (void) saveRemoteAsyncWithTarget:(User *) user error:(NSError *) error;
 */

- (void) saveToCacheAsyncWithTarget:(id)target
                           selector:(SEL)selector;

/**
 * Block version of MaaSModel::saveToCache:
 *
 * This method will asynchronously (using GCD) save an MaaSModel to the web
 * When it completes, it will run the passed in block with the result of the save.
 *
 * @param block the return block.  
 *  The block takes 2 arguments
 *   - saved - a bool that is true on success, and false on failure
 *   - error - an NSError object that will be non nil if the request fails
 */

- (void)saveToCacheWithBlock:(void (^)(BOOL saved, NSError *error))block;

#pragma mark - MaaSive Query Methods

/**
 * Fetches objects from the web with a given query dictionary <b>Synchronously</b>.  
 * Here are the available options for querying.
 *
 * <ul>
 *  <li>.eql (equal)</li>
 *  <li>.lt (less than)</li>
 *  <li>.gt (greater than)</li>
 *  <li>.gte (greater than equal)</li>
 *  <li>.regexp (regular expression search)</li>
 *  <li>.in</li>
 * </ul>
 *
 * WHERE queries are of the form [columnName].[query type]
 * You can also perform sorting and limiting using the following syntax
 * 
 * <ul>
 *   <li>sort</li>
 *   <li>limit</li>
 *   <li>offset</li>
 * </ul>
 *
 * Here is an example for fetching all TaMaaS objects having completed = true
 * and limiting 10 results
 *
 * {
 *      "completed.eql" = "1",
 *      "limit" = 10
 * }
 *
 * @param query an NSDictionary containing the query parameters
 * @param error an NSError pointer that will be non nil if there is an error
 * @returns an NSArray of all MaaSModel objects matching the given query
 */

+ (NSArray *)findRemoteWithQuery:(NSDictionary *)query 
						   error:(NSError **)error;

/**
 * Fetches objects from the web with a given query dictionary <b>Synchronously</b>.  
 * Here are the available options for querying.
 *
 * <ul>
 *  <li>.eql (equal)</li>
 *  <li>.lt (less than)</li>
 *  <li>.gt (greater than)</li>
 *  <li>.gte (greater than equal)</li>
 *  <li>.regexp (regular expression search)</li>
 *  <li>.in</li>
 * </ul>
 *
 * WHERE queries are of the form [columnName].[query type]
 * You can also perform sorting and limiting using the following syntax
 * 
 * <ul>
 *   <li>sort</li>
 *   <li>limit</li>
 *   <li>offset</li>
 * </ul>
 *
 * Here is an example for fetching all TaMaaS objects having completed = true
 * and limiting 10 results
 *
 * {
 *      "completed.eql" = "1",
 *      "limit" = 10
 * }
 *
 * @param query an NSDictionary containing the query parameters
 * @param cacheResults When set to YES, MaaSive will cache all results from the server.
 * this will make subsequent requests much faster.
 * @param error an NSError pointer that will be non nil if there is an error
 * @returns an NSArray of all MaaSModel objects matching the given query
 */

+ (NSArray *)findRemoteWithQuery:(NSDictionary *)query 
					cacheResults:(BOOL)cacheResults 
						   error:(NSError **)error;

/**
 * This is the Asynchronous version of MaaSModel::findRemoteWithQuery:error: when it completes,
 * it will call the passed in selector of the passed in target with an NSArray containing the 
 * the fetched objects.
 *
 * If the request fails, it will pass along a non nil value for the error
 *
 * @param query an NSDictionary containing the query parameters
 * @param cacheResults When set to YES, MaaSive will cache all results from the server.
 * this will make subsequent requests much faster.
 * @param target the delegate class containing the needed callback method
 * @param selector a callback method of the form methodName:error this method should take
 * an NSArray and an NSError.  An example would be <br>
 * - (void) findRemoteUsersCallback:(NSArray *) results error:(NSError *) error;
 */

+ (void) findRemoteAsyncWithQuery:(NSDictionary *)query 
						   target:(id)target
						 selector:(SEL)selector;

/**
 * This is the Asynchronous version of MaaSModel::findRemoteWithQuery:error: when it completes,
 * it will call the passed in selector of the passed in target with an NSArray containing the 
 * the fetched objects.
 *
 * If the request fails, it will pass along a non nil value for the error
 *
 * @param query an NSDictionary containing the query parameters
 * @param target the delegate class containing the needed callback method
 * @param selector a callback method of the form methodName:error this method should take
 * an NSArray and an NSError.  An example would be <br>
 * - (void) findRemoteUsersCallback:(NSArray *) results error:(NSError *) error;
 */

+ (void) findRemoteAsyncWithQuery:(NSDictionary *)query 
					 cacheResults:(BOOL)cacheResults
						   target:(id)target
						 selector:(SEL)selector;

/**
 * Block version of MaaSModel::findRemoteWithQuery:error:
 *
 * This method will asynchronously (using GCD) fetch all MaaSModel objects 
 * matching a specific query and run the passed in block when it has completed.
 *
 * @param query an NSDictionary containing the query parameters  
 * @param block the return block.  
 *  The block takes 2 arguments
 *   - objects - The array of returned objects
 *   - error - an NSError object that will be non nil if the request fails
 */

+ (void)findRemoteWithQuery:(NSDictionary *)query
			completionBlock:(void (^)(NSArray *objects, NSError *error))block;

/**
 * Block version of MaaSModel::findRemoteWithQuery:error:
 *
 * This method will asynchronously (using GCD) fetch all MaaSModel objects 
 * matching a specific query and run the passed in block when it has completed.
 *
 * @param query an NSDictionary containing the query parameters
 * @param cacheResults When set to YES, MaaSive will cache all results from the server.
 * this will make subsequent requests much faster.  
 * @param block the return block.  
 *  The block takes 2 arguments
 *   - objects - The array of returned objects
 *   - error - an NSError object that will be non nil if the request fails
 */

+ (void)findRemoteWithQuery:(NSDictionary *)query
			   cacheResults:(BOOL)cacheResults
			completionBlock:(void (^)(NSArray *objects, NSError *error))block;

#pragma mark - MaaSive Cache Query Methods

/**
 * Same as @See MaaSModel::findRemoteWithQuery:error: except that it fetches from the local
 * cache. The user should use this method before calling findRemoteWithQuery if they want to
 * serve up cached results.
 *
 * @param error an NSError pointer that will be non null in the event of an error
 * @returns an NSArray containing the returned MaaSModel objects.
 */

+ (NSArray *)findCachedWithQuery:(NSDictionary *)query 
                           error:(NSError **)error;

/**
 * This is the Asynchronous version of MaaSModel::findCachedWithQuery:error: when it completes,
 * it will call the passed in selector of the passed in target with an NSArray containing the 
 * the fetched objects.
 *
 * @param query an NSDictionary containing the query parameters
 * @param target the delegate class containing the needed callback method
 * @param selector a callback method of the form methodName:error this method should take
 * an NSArray and an NSError.  An example would be <br>
 * - (void) findRemoteUsersCallback:(NSArray *) results error:(NSError *) error;
 */

+ (void) findCachedAsyncWithQuery:(NSDictionary *)query 
						   target:(id)target
						 selector:(SEL)selector;

/**
 * Block version of MaaSModel::findCachedWithQuery:error:
 *
 * This method will asynchronously (using GCD) fetch all MaaSModel objects from the cache 
 * matching a specific query and run the passed in block when it has completed.
 *
 * @param query an NSDictionary containing the query parameters
 * @param block the return block.  
 *  The block takes 2 arguments
 *   - objects - The array of returned objects
 *   - error - an NSError object that will be non nil if the request fails
 */

+ (void)findCachedWithQuery:(NSDictionary *)query
			completionBlock:(void (^)(NSArray *objects, NSError *error))block;

#pragma mark - MaaSive Query All Methods

/**
 * Fetches all objects from the web of this class
 *
 * @param error an NSError pointer that will be non nil if there is an error
 * @returns an NSArray of all MaaSModel objects matching this class
 */

+ (NSArray *)findAllRemote:(NSError **)error;

/**
 * Fetches all objects from the web of this class
 *
 * @param cacheResults When set to YES, MaaSive will cache all results from the server.
 * @param error an NSError pointer that will be non nil if there is an error
 * @returns an NSArray of all MaaSModel objects matching this class
 */

+ (NSArray *)findAllRemoteCacheResults:(BOOL)cacheResults 
								 error:(NSError **)error;

/**
 * This is the Asynchronous version of MaaSModel::findAllRemote when it completes,
 * it will call the passed in selector of the passed in target with an NSArray containing the 
 * the fetched objects.
 *
 * If the request fails, it will pass along a non nil value for the error
 *
 * @param target the delegate class containing the needed callback method
 * @param selector a callback method of the form methodName:error this method should take
 * an NSArray and an NSError.  An example would be <br>
 * - (void) findRemoteUsersCallback:(NSArray *) results error:(NSError *) error;
 */

+ (void) findAllRemoteAsyncWithTarget:(id)target
							 selector:(SEL)selector;

/**
 * This is the Asynchronous version of MaaSModel::findAllRemoteCacheResults:error when it completes,
 * it will call the passed in selector of the passed in target with an NSArray containing the 
 * the fetched objects.
 *
 * If the request fails, it will pass along a non nil value for the error
 *
 * @param cacheResults When set to YES, MaaSive will cache all results from the server.
 * @param target the delegate class containing the needed callback method
 * @param selector a callback method of the form methodName:error this method should take
 * an NSArray and an NSError.  An example would be <br>
 * - (void) findRemoteUsersCallback:(NSArray *) results error:(NSError *) error;
 */

+ (void) findAllRemoteAsyncCacheResults:(BOOL)cacheResults
								 target:(id)target
							   selector:(SEL)selector;

/**
 * Block version of MaaSModel::findAllRemote
 *
 * This method will asynchronously (using GCD) fetch all MaaSModel objects 
 * matching a specific query and run the passed in block when it has completed.
 *
 * @param block the return block.  
 *  The block takes 2 arguments
 *   - objects - The array of returned objects
 *   - error - an NSError object that will be non nil if the request fails
 */

+ (void)findAllRemoteWithCompletionBlock:(void (^)(NSArray *objects, NSError *error))block;

/**
 * Block version of MaaSModel::findAllRemoteCacheResults:error:
 *
 * This method will asynchronously (using GCD) fetch all MaaSModel objects 
 * matching a specific query and run the passed in block when it has completed.
 *
 * @param cacheResults When set to YES, MaaSive will cache all results from the server.
 * this will make subsequent requests much faster.  
 * @param block the return block.  
 *  The block takes 2 arguments
 *   - objects - The array of returned objects
 *   - error - an NSError object that will be non nil if the request fails
 */

+ (void)findAllRemoteCacheResults:(BOOL)cacheResults
				  completionBlock:(void (^)(NSArray *objects, NSError *error))block;

#pragma mark - MaaSive Query Count Methods

/**
 * Fetches the count of all remote MaaSModels matching a given query.
 *
 * @See MaaSModel::findRemoteWithQuery:error: for more info on how to create a
 * query.
 *
 * @param query an NSDictionary containing the query parameters
 * @param error an NSError pointer that will be non nil if there is an error
 * @returns The count of all objects matching the query
 */

+ (NSInteger)findRemoteCountWithQuery:(NSDictionary *)query 
								error:(NSError **)error;

/**
 * This is the Asynchronous version of MaaSModel::findRemoteCountWithQuery:error: when it completes,
 * it will call the passed in selector of the passed in target with an NSNumber containing the count 
 * of objects matching the query.  
 *
 * If the request fails, it will pass along a non nil value for the error
 *
 * @param query an NSDictionary containing the query parameters
 * @param target the delegate class containing the needed callback method
 * @param selector a callback method of the form methodName:error this method should take
 * an NSNumber and an NSError.  An example would be <br>
 * - (void) findRemoteUsersCountCallback:(NSNumber *) count error:(NSError *) error;
 */

+ (void) findRemoteCountAsyncWithQuery:(NSDictionary *)query 
								target:(id)target
							  selector:(SEL)selector;

/**
 * Block version of MaaSModel::findRemoteCountWithQuery:error:
 *
 * This method will asynchronously (using GCD) fetch the count of all MaaSModel objects 
 * matching a specific query and run the passed in block when it has completed.
 *
 * @param query an NSDictionary containing the query parameters
 * @param block the return block.  
 *  The block takes 2 arguments
 *   - count - The number of objects matching the query
 *   - error - an NSError object that will be non nil if the request fails
 */

+ (void)findRemoteCountWithQuery:(NSDictionary *)query 
				 completionBlock:(void (^)(NSInteger count, NSError *error))block;

#pragma mark - MaaSive Query Count Methods

/**
 * Fetches the count of all cached MaaSModels matching a given query.
 *
 * @See MaaSModel::findRemoteWithQuery:error: for more info on how to create a
 * query.
 *
 * @param query an NSDictionary containing the query parameters
 * @param error an NSError pointer that will be non nil if there is an error
 * @returns The count of all objects matching the query
 */

+ (NSInteger)findCachedCountWithQuery:(NSDictionary *)query 
								error:(NSError **)error;

/**
 * This is the Asynchronous version of MaaSModel::findCachedCountWithQuery:error: when it completes,
 * it will call the passed in selector of the passed in target with an NSNumber containing the count 
 * of objects matching the query in the cache.  
 *
 * If the request fails, it will pass along a non nil value for the error
 *
 * @param query an NSDictionary containing the query parameters
 * @param target the delegate class containing the needed callback method
 * @param selector a callback method of the form methodName:error this method should take
 * an NSNumber and an NSError.  An example would be <br>
 * - (void) findRemoteUsersCountCallback:(NSNumber *) count error:(NSError *) error;
 */

+ (void) findCachedCountAsyncWithQuery:(NSDictionary *)query 
								target:(id)target
							  selector:(SEL)selector;

/**
 * Block version of MaaSModel::findCachedCountWithQuery:error:
 *
 * This method will asynchronously (using GCD) fetch the count of all MaaSModel objects 
 * matching a specific query and run the passed in block when it has completed.
 *
 * @param query an NSDictionary containing the query parameters
 * @param block the return block.  
 *  The block takes 2 arguments
 *   - count - The number of objects matching the query in the cache
 *   - error - an NSError object that will be non nil if the request fails
 */

+ (void)findCachedCountWithQuery:(NSDictionary *)query 
				 completionBlock:(void (^)(NSInteger count, NSError *error))block;


#pragma mark - MaaSive Removal Methods

/**
 * Deletes an MaaSModel from the web.  This method must be called on an existing
 * MaaSModel as it references the _id field that was generated on the web.
 *
 * @param error an NSError pointer that will be non nil if there is an error
 * @returns a boolean that is YES upon success and NO on failure
 */

- (BOOL)removeRemote: (NSError **)error;

/**
 * Deletes an MaaSModel from the web.  This method must be called on an existing
 * MaaSModel as it references the _id field that was generated on the web.
 *
 * @param error an NSError pointer that will be non nil if there is an error
 * @returns a boolean that is YES upon success and NO on failure
 */

- (BOOL)removeRemote: (NSError **)error
		cacheResults:(BOOL)cacheResults;

/**
 * This is the Asynchronous version of MaaSModel::removeRemote: when it completes,
 * it will call the passed in selector of the passed in target with the MaaSModel subclass 
 * that was just removed.
 *
 * If the request fails, it will pass along a non nil value for the error
 *
 * @param target the delegate class containing the needed callback method
 * @param selector a callback method of the form methodName:error this method should take
 * a MaaSModel subclass and an NSError.  An example would be <br>
 * - (void) removeRemoteAsyncWithTarget:(User *) user error:(NSError *) error;
 */

- (void) removeRemoteAsyncWithTarget:(id)target
							selector:(SEL)selector;

/**
 * This is the Asynchronous version of MaaSModel::removeRemote: when it completes,
 * it will call the passed in selector of the passed in target with the MaaSModel subclass 
 * that was just removed.
 *
 * If the request fails, it will pass along a non nil value for the error
 *
 * @param target the delegate class containing the needed callback method
 * @param selector a callback method of the form methodName:error this method should take
 * a MaaSModel subclass and an NSError.  An example would be <br>
 * - (void) removeRemoteAsyncWithTarget:(User *) user error:(NSError *) error;
 */

- (void) removeRemoteAsyncWithTarget:(id)target
							selector:(SEL)selector
						cacheResults:(BOOL)cacheResults;

/**
 * Block version of MaaSModel::removeRemote:
 *
 * This method will asynchronously (using GCD) remove an MaaSModel frome the web
 * When it completes, it will run the passed in block with the result of the remove.
 *
 * @param block the return block.  
 *  The block takes 2 arguments
 *   - removed - a bool that is true on success, and false on failure
 *   - error - an NSError object that will be non nil if the request fails
 */

- (void)removeRemoteWithBlock:(void (^)(BOOL removed, NSError *error))block;

/**
 * Block version of MaaSModel::removeRemote:
 *
 * This method will asynchronously (using GCD) remove an MaaSModel frome the web
 * When it completes, it will run the passed in block with the result of the remove.
 *
 * @param block the return block.  
 *  The block takes 2 arguments
 *   - removed - a bool that is true on success, and false on failure
 *   - error - an NSError object that will be non nil if the request fails
 */

- (void)removeRemoteWithCachedResults:(BOOL)cacheResults
                      completionBlock:(void (^)(BOOL removed, NSError *error))block;

#pragma mark - MaaSive Cache Removal Methods

/**
 * Deletes an MaaSModel from the cache.  This method must be called on an existing
 * MaaSModel as it references the _id field that was generated on the web.
 *
 * @param error an NSError pointer that will be non nil if there is an error
 * @returns a boolean that is YES upon success and NO on failure
 */

- (BOOL)removeFromCache:(NSError **)error;

/**
 * This is the Asynchronous version of MaaSModel::removeRemote: when it completes,
 * it will call the passed in selector of the passed in target with the MaaSModel subclass 
 * that was just removed.
 *
 * If the request fails, it will pass along a non nil value for the error
 *
 * @param target the delegate class containing the needed callback method
 * @param selector a callback method of the form methodName:error this method should take
 * a MaaSModel subclass and an NSError.  An example would be <br>
 * - (void) removeRemoteAsyncWithTarget:(User *) user error:(NSError *) error;
 */

- (void) removeFromCacheAsyncWithTarget:(id)target
                               selector:(SEL)selector;

/**
 * Block version of MaaSModel::removeFromCache:
 *
 * This method will asynchronously (using GCD) remove an MaaSModel frome the cache
 * When it completes, it will run the passed in block with the result of the remove.
 *
 * @param block the return block.  
 *  The block takes 2 arguments
 *   - removed - a bool that is true on success, and false on failure
 *   - error - an NSError object that will be non nil if the request fails
 */

- (void)removeFromCacheWithBlock:(void (^)(BOOL removed, NSError *error))block;

@end
