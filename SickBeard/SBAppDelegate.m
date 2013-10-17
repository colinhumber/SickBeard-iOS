//
//  SBAppDelegate.m
//  SickBeard
//
//  Created by Colin Humber on 8/26/11.
//  Copyright (c) 2011 Colin Humber. All rights reserved.
//

#import "SBAppDelegate.h"
#import "SBServer.h"
#import "SBServerDetailsViewController.h"
#import "SickbeardAPIClient.h"

@implementation SBAppDelegate

@synthesize window = _window;

+ (void)initialize {
	NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)applyStylesheet {
	[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"menu-bar"] 
									   forBarMetrics:UIBarMetricsDefault];
	[[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"toolbar-bar"]
							forToolbarPosition:UIToolbarPositionBottom
									barMetrics:UIBarMetricsDefault];
	[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:RGBCOLOR(127, 92, 59)];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[TestFlight takeOff:@"ba7e0bec-92a4-4478-b663-660225c13db1"];
		
	NSURLCache *urlCache = [[NSURLCache alloc] initWithMemoryCapacity:1024*1024   // 1MB mem cache
														 diskCapacity:1024*1024*5 // 5MB disk cache
															 diskPath:nil];
	[NSURLCache setSharedURLCache:urlCache];
	
	SBServer *server = [NSUserDefaults standardUserDefaults].server;
	
	if (!server) {
		[self.window makeKeyAndVisible];

		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
		SBServerDetailsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([SBServerDetailsViewController class])];
		
		UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
		
		[self.window.rootViewController presentViewController:nav animated:NO completion:nil];
	}
	else {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		SickbeardAPIClient *client = [[SickbeardAPIClient alloc] initWithBaseURL:[NSURL URLWithString:defaults.server.serviceEndpointPath]];
		[client loadDefaults];
//		[SickbeardAPIClient sharedClient].currentServer = server;
		[self.window makeKeyAndVisible];
	}
	
	[self applyStylesheet];
	
    return YES;
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

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

@end
