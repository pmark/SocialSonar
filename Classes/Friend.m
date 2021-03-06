//
//  Friend.m
//  Beacon
//
//  Created by P. Mark Anderson on 11/21/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

#import "Friend.h"
#import "SoSoAppDelegate.h"
#import "CJSONDeserializer.h"

@implementation Friend

@dynamic name;
@dynamic accessToken;
@dynamic visible;
@dynamic createdAt;
@dynamic invitationToken;
@dynamic serverURL;


+ (Friend *) dummy
{
    Friend *friend = [[Friend alloc] init];
    
    friend.name = @"Dummy";
    friend.createdAt = [NSDate date];
    
    return friend;
}

- (id) initWithName:(NSString *)_name
{
    if (self = [super init])
    {
        self.name = _name;
    }
    
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@, %@\n%@", [self accessToken], [self serverURL], [self name]];
}

- (void) setVisible:(BOOL)_visible
{
    self.visible = _visible;
    
    // TODO: deactivate shared link temporarily
    
}

- (void) acceptInvitation
{
}

- (void) denyInvitation
{
}

- (void) handleInvitation:(NSString *)newInvitationCode
{
}

#pragma mark -

- (LQHTTPRequestCallback)getAccessTokenCallback {
	if (getAccessTokenCallback) return getAccessTokenCallback;
    
    return getAccessTokenCallback = [^(NSError *error, NSString *responseBody) 
             {
                 NSLog(@"Fetching access token.");
                 
                 NSError *err = nil;
                 NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:
                                                                                                NSUTF8StringEncoding]
                                                                                         error:&err];
                 if (!res || [res objectForKey:@"error"] != nil) 
                 {
                     NSLog(@"Error deserializing response (for invitation/token) \"%@\": %@", responseBody, err);
                     [[Geoloqi sharedInstance] errorProcessingAPIRequest];
                     return;
                 }
                 
                 
                 NSLog(@"Fetched token: %@", res);
                 
                 self.accessToken = [res objectForKey:@"access_token"];
                 
                 // Commit the change.
                 NSError *saveError;
                 
                 NSLog(@"Saving friend's accessToken: %@", self.accessToken);
                 
                 if (![MOCONTEXT save:&saveError]) 
                 {
                     NSLog(@"ERROR saving friend's access token: %@", [saveError localizedDescription]);        
                 }                     
                 
                 
             } copy];
}

- (void) getAccessToken
{
    NSString *token = [self invitationToken];
    NSString *server = [self serverURL];
    
    NSLog(@"Asking %@ for invitation %@", server, token);
    
    // TODO: use an operation queue
    [[Geoloqi sharedInstance] getAccessTokenForInvitation:token callback:[self getAccessTokenCallback]];
    
}

+ (void) getOpenAccessTokens
{
    for (Friend *oneFriend in [Friend allFriends])
    {
        NSString *atok = [oneFriend accessToken];
        NSString *itok = [oneFriend invitationToken];
        
        if ([atok length] > 0)
        {
            NSLog(@"Friend with invitationToken '%@' already has accessToken '%@'", 
                  itok, atok);
            continue;            
        }
        
        
        if ([itok length] > 0)
        {
            NSLog(@"Checking friend with invitationToken '%@'", itok);        
            [oneFriend getAccessToken];
        }
    }
    
}

+ (NSMutableArray *) allFriends
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend" 
                                              inManagedObjectContext:MOCONTEXT];
    
    [request setEntity:entity];
    
    // Order the friends by creation date, most recent first.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];

    [sortDescriptor release];
    [sortDescriptors release];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[MOCONTEXT executeFetchRequest:request error:&error] mutableCopy];
    
    if (mutableFetchResults == nil) 
    {
        NSLog(@"ERROR fetching friends: %@", [error localizedDescription]);        
    }
    
    NSLog(@"Found %i friends.", [mutableFetchResults count]);
    
    [request release];   
    
    return [mutableFetchResults autorelease];
}    

+ (NSMutableArray *) allFriendAccessTokens
{
    NSArray *friends = [Friend allFriends];
    
    if (!friends || [friends count] == 0)
        return nil;
    
    NSMutableArray *tokens = [NSMutableArray arrayWithCapacity:[friends count]];
    
    for (Friend *friend in friends)
    {
        NSString *t = friend.accessToken;
        
        if (!t)
            continue;
        
        [tokens addObject:t];
    }
    
    return tokens;
}

#pragma mark -

@end
