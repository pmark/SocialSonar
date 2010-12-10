//
//  BeaconAppDelegate.h
//  Beacon
//
//  Created by P. Mark Anderson on 11/21/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Geoloqi.h"
#import "InvitationController.h"

@interface BeaconAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> 
{
    UIWindow *window;
    UITabBarController *tabBarController;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    LQHTTPRequestCallback getInvitationCallback;
    
    NSDictionary *currentInvitation;
    InvitationController *invitationController;
    NSString *invitationHost;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;
@property (nonatomic, retain) InvitationController *invitationController;
@property (nonatomic, retain) NSString *invitationHost;

- (NSString *) html:(NSString *)urn;
- (NSString *) apiServerURL;

+ (void)alertWithTitle:(NSString *)title message:(NSString *)msg;

@end

#define APP_DELEGATE ((BeaconAppDelegate*)[UIApplication sharedApplication].delegate)
#define MOCONTEXT APP_DELEGATE.managedObjectContext
