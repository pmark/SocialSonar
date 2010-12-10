//
//  Friend.h
//  Beacon
//
//  Created by P. Mark Anderson on 11/21/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

#import "Geoloqi.h"

@interface Friend : NSManagedObject  
{
    LQHTTPRequestCallback getAccessTokenCallback;
}

- (id) initWithName:(NSString *)name;
+ (NSMutableArray *) allFriends;
+ (void) getOpenAccessTokens;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSString *invitationToken;
@property (nonatomic, retain) NSString *serverURL;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, retain) NSDate *createdAt;

@end



