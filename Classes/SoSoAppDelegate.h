//
//  SoSoAppDelegate.h
//  Beacon
//
//  Created by P. Mark Anderson on 11/21/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Geoloqi.h"
#import "LQConstants.h"
#import "Constants.h"
#import "InvitationController.h"
#import "MapController.h"
#import "NicknameController.h"

@interface SoSoAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, NicknameDelegate> 
{
    UIWindow *window;
    MapController *mapController;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    LQHTTPRequestCallback getInvitationCallback;
    LQHTTPRequestCallback createPermanentAccessTokenCallback;
    
    NSDictionary *currentInvitation;
    InvitationController *invitationController;
    NSString *invitationHost;
    NSString *permanentAccessToken;
    NSString *nickname;
    NicknameController *nicknameController;
    BOOL invitationViewingDisabled;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;
@property (nonatomic, retain) InvitationController *invitationController;
@property (nonatomic, retain) NSString *invitationHost;
@property (nonatomic, retain) NSString *permanentAccessToken;
@property (nonatomic, retain) NSString *nickname;
@property (nonatomic, assign) BOOL invitationViewingDisabled;

- (NSString *) html:(NSString *)urn;
- (NSString *) apiServerURL;
- (NSString *) apiServerHost;

+ (void)alertWithTitle:(NSString *)title message:(NSString *)msg;
- (LQHTTPRequestCallback)createPermanentAccessTokenCallback;
- (LQHTTPRequestCallback)getInvitationCallback;
- (NSString *) fullyQualifiedHost:(NSString *)h;
- (void) createFriend:(NSDictionary *)data withAccessToken:(NSString *)accessToken;

@end

#define APP_DELEGATE ((SoSoAppDelegate*)[UIApplication sharedApplication].delegate)
#define MOCONTEXT APP_DELEGATE.managedObjectContext
