//
//  NSManagedObjectContext+MaaSive.h
//  StratusKit
//
//  Created by Collin Ruffenach on 6/27/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

/**
 * The NSManagedObjectContext_MaaSive category is an extension of Apple's
 * NSManagedObjectContext that provides hooks into the MaaSive Cloud. The
 * category provides methods for both saving to MaaSive and querying 
 * MaaSive.
 */

@interface NSManagedObjectContext(NSManagedObjectContext_MaaSive)

#pragma mark - Saving Methods

/**
 * Synchronizes the managed object context with the web.  If this is a new synced entity 
 * (ie it is a MaaSEntity subentity and its MaaSID property is nil), it will create a 
 * new record on the server, otherwise it will perform an update on the existing managed 
 * object. Call this method anytime you want to save uncommited MaaSEntities to the cloud.
 *
 * @param error an NSError pointer that will be non nil if there is an error
 * @returns a boolean that is YES upon success and NO on failure
 */

-(BOOL)saveRemote:(NSError**)error;

/**
 * Async callback version of NSManagedObjectContext::saveRemote:
 *
 * This method will asynchronously (using GCD) save the managed object context to the web
 * When it completes, it will call the passed in selector on the passed in target
 *
 * @param target the taget that the supplied selector will be performed on  upon completion of remote save
 * @param selector the selector that will be performed on the supplied target upon completion of remote save
 */

-(void)saveRemoteAsyncWithTarget:(id)target
						selector:(SEL)selector;

/**
 * Block version of NSManagedObjectContext::saveRemote:
 *
 * This method will asynchronously (using GCD) save the managed object context to the web
 * When it completes, it will run the passed in block with the result of the save.
 *
 * @param block the return block.  
 *  The block takes 2 arguments
 *   - saved - a bool that is true on success, and false on failure
 *   - error - an NSError object that will be non nil if the request fails
 */

- (void)saveRemoteWithBlock:(void (^)(BOOL saved, NSError *error))block;

#pragma mark - Deleting Methods

/**
 * Deletes the objects in the array from MaaSive. If the objects are not saved
 * to MaaSive, they are ignored. Objects deleted from the ManagedObjectContext
 * and then saved with NSManagedObjectContext's save: method will not be deleted.
 * Remote deletes must be explicity called.
 *
 * @param objects an Array of all the NSManagedObject MaaSEntity subenities to be deleted
 * @param error an NSError pointer that will be non nil if there is an error
 * @returns a boolean that is YES upon success and NO on failure
 */

- (BOOL)deleteRemoteObjects:(NSArray*)objects 
					  error:(NSError**)error;

/**
 * Async callback version of NSManagedObjectContext::deleteRemoteObjects:error:
 *
 * This method will asynchronously (using GCD) delete the managed objects from the web
 * When it completes, it will call the passed in selector on the passed in target
 *
 * @param objects an Array of all the NSManagedObject MaaSEntity subenities to be deleted
 * @param error an NSError pointer that will be non nil if there is an error
 * @returns a boolean that is YES upon success and NO on failure
 */

-(void)deleteRemoteObjectsAsync:(NSArray*)objects 
					 withTarget:(id)target
					   selector:(SEL)selector;

/**
 * Block version of NSManagedObjectContext::deleteRemoteObjects:error:
 *
 * This method will asynchronously (using GCD) delete the managed objects from the web
 * When it completes, it will run the passed in block with the result of the save.
 *
 * @param target the taget that the supplied selector will be performed on upon completion of remote delete
 * @param selector the selector that will be performed on the supplied target upon completion of remote delete
 * @returns a boolean that is YES upon success and NO on failure
 */

- (void)deleteRemoteObjects:(NSArray*)objects
			completionBlock:(void (^)(BOOL saved, NSError *error))block;

#pragma mark - Find All Methods

/**
 * Fetches EVERY object of the given entity description from the web and returns them.
 * as managed objects. These objects are added to you context and saved as well. If there
 * are existing managed objects with the returned MaaSID's those will be updated instead.
 *
 * @param entity an NSEntityDescription that specifies the entity to find in MaaSive
 * @param error an NSError pointer that will be non null in the event of an error
 * @returns an NSArray containing the returned MaaSModel objects.
 */

- (NSArray*)findAllRemoteForEntity:(NSEntityDescription*)entity 
							 error:(NSError**)error;

/**
 * Async callback version of NSManagedObjectContext::findAllRemoteForEntity:error:
 *
 * This method will asynchronously (using GCD) fetch all managed objects 
 * matching a specific entity and run the passed in selector on the passed 
 * in target
 *
 * @param entity an NSEntityDescription that specifies the entity to find in MaaSive
 * @param target the callback target for the selector you provide
 * @param selector the selector to call on the target provided on completion
 */

-(void)findAllRemoteAsyncForEntity:(NSEntityDescription*)entity 
							target:(id)target 
						  selector:(SEL)selector;

/**
 * Block version of NSManagedObjectContext::findAllRemoteForEntity:error: 
 *
 * This method will asynchronously (using GCD) fetch all managed objects 
 * oh the passed in entity and run the passed in block when it has completed.
 *
 * @param entity an NSEntityDescription that specifies the entity to find in MaaSive
 * @param block the return block.  
 *  The block takes 2 arguments
 *   - objects - The array of returned objects
 *   - error - an NSError object that will be non nil if the request fails
 */

- (void)findAllRemoteForEntity:(NSEntityDescription*)entity 
			   completionBlock:(void (^)(NSArray *objects, NSError *error))block;

#pragma mark - Query Methods

/**
 * Fetches objects of the passed in entity description typefrom the web 
 * with a given query dictionary <b>Synchronously</b>. Here are the available 
 * options for querying.
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
 * @param entity an NSEntityDescription that specifies the entity to find in MaaSive
 * @param query an NSDictionary containing the query parameters
 * @param error an NSError pointer that will be non nil if there is an error
 * @returns an NSArray of all MaaSModel objects matching the given query
 */

-(NSArray *)findRemoteForEntity:(NSEntityDescription*)entity 
					  withQuery:(NSDictionary *)query 
						  error:(NSError**)error;

/**
 * Async callback version of NSManagedObjectContext::findAllRemoteForEntity:error:
 *
 * This method will asynchronously (using GCD) fetch all managed objects 
 * matching a specific query and entity and run the passed in selector on the 
 * passed in target
 *
 * @param entity an NSEntityDescription that specifies the entity to find in MaaSive
 * @param query an NSDictionary containing the query parameters
 * @param target the callback target for the selector you provide
 * @param selector the selector to call on the target provided on completion
 */

-(void)findRemoteAsyncForEntity:(NSEntityDescription*)entity 
					  withQuery:(NSDictionary *)query
						 target:(id) target 
					   selector:(SEL)selector;

/**
 * Block version of NSManagedObjectContext::findAllRemoteForEntity:error:
 *
 * This method will asynchronously (using GCD) fetch all managed objects 
 * matching a specific query and entity and run the passed in block when 
 * it has completed.
 *
 * @param entity an NSEntityDescription that specifies the entity to find in MaaSive
 * @param query an NSDictionary containing the query parameters
 * @param block the return block.  
 *  The block takes 2 arguments
 *   - objects - The array of returned objects
 *   - error - an NSError object that will be non nil if the request fails
 */

- (void)findRemoteForEntity:(NSEntityDescription*)entity
				  withQuery:(NSDictionary *)query
			completionBlock:(void (^)(NSArray *objects, NSError *error))block;

#pragma mark - Find All Count Methods

/**
 * Fetches the count of all remote managed objects matching a certin Entity.
 *
 * @param entity an NSEntityDescription that specifies the entity to find in MaaSive
 * @param error an NSError pointer that will be non nil if there is an error
 * @returns The count of all objects matching the Entity type
 */

- (NSUInteger)findRemoteCountForEntity:(NSEntityDescription *)entity 
								 error:(NSError**)error;

/**
 * Fetches the count of all remote managed objects matching a certin Entity
 *
 * @See NSManagedObjectContext::findRemoteForEntity:error for more info on how to create a
 * query.
 *
 * @param entity an NSEntityDescription that specifies the entity to find in MaaSive
 * @param target a target to perform the supplied selector on upon completion
 * @param selector a selector to performed the supplied target on upon completion
 * @returns The count of all objects matching the Entity type
 */

-(void)findRemoteCountAsyncForEntity:(NSEntityDescription*)entity 
							  target:(id)target 
							selector:(SEL)selector;

/**
 * Block version of NSManagedObjectContext::findRemoteCountForEntity:error: 
 *
 * This method will asynchronously (using GCD) fetch all managed objects matching
 * the provided entity and run the passed in block when it has completed.
 *
 * @param entity an NSEntityDescription that specifies the entity to find in MaaSive
 * @param block the return block.  
 *  The block takes 2 arguments
 *   - objects - The array of returned objects
 *   - error - an NSError object that will be non nil if the request fails
 */

- (void)findRemoteCountForEntity:(NSEntityDescription *)entity 
				 completionBlock:(void (^)(NSInteger count, NSError *error))block;

#pragma mark - Find Count with Query Methods

/**
 * Fetches the count of all remote managed objects matching a certin Entity and query
 *
 * @See NSManagedObjectContext::findRemoteForEntity:withQuery:error for more info on how to create a
 * query.
 *
 * @param entity an NSEntityDescription that specifies the entity to find in MaaSive
 * @param query an NSDictionary containing the query parameters
 * @param error an NSError pointer that will be non nil if there is an error
 * @returns The count of all objects matching the Entity type
 */

- (NSUInteger)findRemoteCountForEntity:(NSEntityDescription*)entity 
							 withQuery:(NSDictionary *)query 
								 error:(NSError**)error;

/**
 * Fetches the count of all remote managed objects matching a certin Entity and query
 *
 * @See NSManagedObjectContext::findRemoteForEntity:withQuery:error for more info on how to create a
 * query.
 *
 * @param entity an NSEntityDescription that specifies the entity to find in MaaSive
 * @param query an NSDictionary containing the query parameters
 * @param target a target to perform the supplied selector on upon completion
 * @param selector a selector to performed the supplied target on upon completion
 * @returns The count of all objects matching the Entity type
 */

-(void)findRemoteCountAsyncForEntity:(NSEntityDescription*)entity 
						   withQuery:(NSDictionary *)query 
							  target:(id) target
							selector:(SEL)selector;

/**
 * Block version of NSManagedObjectContext::findRemoteCountForEntity:withQuery:error: 
 *
 * This method will asynchronously (using GCD) fetch all managed objects matching
 * the provided entity and query and run the passed in block when it has completed.
 *
 * @param entity an NSEntityDescription that specifies the entity to find in MaaSive
 * @param query an NSDictionary containing the query parameters
 * @param block the return block.  
 *  The block takes 2 arguments
 *   - objects - The array of returned objects
 *   - error - an NSError object that will be non nil if the request fails
 */

- (void)findRemoteCountForEntity:(NSEntityDescription*)entity 
					   withQuery:(NSDictionary *)query
				 completionBlock:(void (^)(NSInteger count, NSError *error))block;

@end
