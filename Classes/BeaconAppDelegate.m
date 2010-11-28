//
//  BeaconAppDelegate.m
//  Beacon
//
//  Created by P. Mark Anderson on 11/21/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

#import "BeaconAppDelegate.h"
#import "InvitationController.h"


@implementation BeaconAppDelegate

@synthesize window;
@synthesize tabBarController;


- (void)dealloc {
    [tabBarController release];
    [window release];
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	NSManagedObjectContext *context = [self managedObjectContext];

	if (!context) 
    {
		// Handle the error.
        NSLog(@"ERROR: Could not init Core Data.");
	}
    
    // Add the tab bar controller's view to the window and display.
    [self.window addSubview:tabBarController.view];
    [self.window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


#pragma mark -
#pragma mark UITabBarControllerDelegate methods

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application 
{	
    NSError *error;
    
    if (managedObjectContext != nil) 
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) 
        {
			// Handle the error.
        } 
    }
}


#pragma mark -
#pragma mark Saving

- (IBAction)saveAction:(id)sender 
{
	
    NSError *error;
    
    if (![[self managedObjectContext] save:&error]) 
    {
		// Handle error
    }
}


#pragma mark -
#pragma mark Core Data stack

- (NSManagedObjectContext *) managedObjectContext 
{
	
    if (managedObjectContext != nil) 
    {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) 
    {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel 
{
	
    if (managedObjectModel != nil) 
    {
        return managedObjectModel;
    }
    
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
	
    if (persistentStoreCoordinator != nil) 
    {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Beacon.sqlite"]];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) 
    {
        // Handle the error.
    }    
	
    return persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory 
{	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0]:nil;
    return basePath;
}

#pragma mark -

- (NSString *) htmlFilePath:(NSString *)urn 
{
    return [[NSBundle mainBundle] pathForResource:urn ofType:@"html"];
}

- (NSString *) htmlBaseURL 
{
    return [[@"file://" stringByAppendingString:[[NSBundle mainBundle] resourcePath]] stringByAppendingString:@"/"];
}

- (NSString *) html:(NSString *)urn 
{
    NSString *filePath = [self htmlFilePath:urn];
    
    if (filePath == nil) 
    {
        NSLog(@"[ERROR] No HTML file for '%@'", urn);
        return nil;
    }
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];  
    NSError *error = nil;
    
    NSString *html = [NSString stringWithContentsOfURL:fileURL 
                                              encoding:NSUTF8StringEncoding
                                                 error:&error];
    
    if (error) 
    {
        NSLog(@"Error getting HTML: %@", [error localizedDescription]);
    }
    
    return [html stringByReplacingOccurrencesOfString:@"{{BASE_URL}}" withString:[self htmlBaseURL]];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (!url) 
    { 
        return NO;
    }
    
    NSString *URLString = [url absoluteString];
    NSLog(@"Opened app with URL: %@", URLString);
    
    NSString *base = [url host];
    NSLog(@"Base: %@", base);
    
    if ([base isEqualToString:@"invitation"])
    {
        NSLog(@"path: %@", [url pathComponents]);
        NSString *invitationCode = [[url pathComponents] objectAtIndex:1];
        NSLog(@"invitation code: %@", invitationCode);

        InvitationController *invite = [[InvitationController alloc] initWithInvitationCode:invitationCode];
        
        for (UIViewController *c in [tabBarController viewControllers])
        {
            [c dismissModalViewControllerAnimated:NO];
        }
        
        [self.tabBarController presentModalViewController:invite animated:NO];
        
        [invite release];
    }    
    
    return YES;
}

@end

