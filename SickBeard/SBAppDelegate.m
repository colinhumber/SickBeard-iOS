//
//  SBAppDelegate.m
//  SickBeard
//
//  Created by Colin Humber on 8/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBAppDelegate.h"
#import "SBServer.h"
#import "SBServerDetailsViewController.h"
#import "SickbeardAPIClient.h"
//#import "TestFlight.h"

@implementation SBAppDelegate

@synthesize window = _window;
//@synthesize managedObjectContext = __managedObjectContext;
//@synthesize managedObjectModel = __managedObjectModel;
//@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (void)registerDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if (!defaults.defaultsRegistered) {
		defaults.status = @"Wanted";
		defaults.initialQualities = [NSArray arrayWithObject:@"SD TV"];
		defaults.archiveQualities = [NSArray arrayWithObject:@"SD DVD"];
		defaults.useSeasonFolders = YES;
		defaults.defaultsRegistered = YES;
		
		[defaults synchronize];
	}
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[TestFlight takeOff:@"1UXYHxdTJuVnGyhcnnzVJskFbBD6NeEKllTqI8JUjJQ"];
	[self registerDefaults];
    // Override point for customization after application launch.

//	MaaSManager *manager = [MaaSManager sharedManager];
//	manager.appId = @"4c96130105e369267a20b54e";
//	manager.secretKey = @"c82fb6f8cc24d58b27f1fd0d4758363ea61fa63d89d195f61a75c39f32ee3ceb4cc4336191";

	SBServer *server = [NSUserDefaults standardUserDefaults].server;
	
	if (!server) {
		[self.window makeKeyAndVisible];

		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
		SBServerDetailsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SBServerDetailsViewController"];
//		vc.managedObjectContext = self.managedObjectContext;
		
		UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
		
		[self.window.rootViewController presentViewController:nav animated:NO completion:nil];
	}
	else {
		[SickbeardAPIClient sharedClient].currentServer = server;
		[self.window makeKeyAndVisible];
	}
	
	

//	if (![NSUserDefaults standardUserDefaults].serverHasBeenSetup) {
//
//		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//		SBServerDetailsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SBServerDetailsViewController"];
//		vc.managedObjectContext = self.managedObjectContext;
//		
//		UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
//		
//		[self.window.rootViewController presentViewController:nav animated:NO completion:nil];
//		//[self.window.rootViewController presentViewController:addServerController animated:YES completion:nil];
//	}
//	else {
//		NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SBServer"];
//		NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];
//		
//		[SickbeardAPIClient sharedClient].currentServer = [results objectAtIndex:0];
//	}

    return YES;
}

- (void)dealloc {
	[_window release];
//	[__managedObjectContext release];
//	[__managedObjectModel release];
//	[__persistentStoreCoordinator release];
	[super dealloc];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
}

//- (void)saveContext
//{
//    NSError *error = nil;
//    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
//    if (managedObjectContext != nil)
//    {
//        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
//        {
//            /*
//             Replace this implementation with code to handle the error appropriately.
//             
//             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
//             */
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        } 
//    }
//}

//#pragma mark - Core Data stack
//
///**
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
// */
//- (NSManagedObjectContext *)managedObjectContext
//{
//    if (__managedObjectContext != nil)
//    {
//        return __managedObjectContext;
//    }
//    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (coordinator != nil)
//    {
//        __managedObjectContext = [[NSManagedObjectContext alloc] init];
//        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
//    }
//    return __managedObjectContext;
//}
//
///**
// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
// */
//- (NSManagedObjectModel *)managedObjectModel
//{
//    if (__managedObjectModel != nil)
//    {
//        return __managedObjectModel;
//    }
//    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SickBeard" withExtension:@"momd"];
//    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    return __managedObjectModel;
//}
//
///**
// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
// */
//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
//{
//    if (__persistentStoreCoordinator != nil)
//    {
//        return __persistentStoreCoordinator;
//    }
//    
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SickBeard.sqlite"];
//    
//    NSError *error = nil;
//    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
//    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
//    {
//        /*
//         Replace this implementation with code to handle the error appropriately.
//         
//         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
//         
//         Typical reasons for an error here include:
//         * The persistent store is not accessible;
//         * The schema for the persistent store is incompatible with current managed object model.
//         Check the error message to determine what the actual problem was.
//         
//         
//         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
//         
//         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
//         * Simply deleting the existing store:
//         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
//         
//         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
//         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
//         
//         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
//         
//         */
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }    
//    
//    return __persistentStoreCoordinator;
//}
//
//#pragma mark - Application's Documents directory
//
///**
// Returns the URL to the application's Documents directory.
// */
//- (NSURL *)applicationDocumentsDirectory
//{
//    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//}

@end
