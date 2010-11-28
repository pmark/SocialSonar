//
//  Friend.m
//  Beacon
//
//  Created by P. Mark Anderson on 11/21/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

#import "Friend.h"


@implementation Friend

@dynamic name;
@dynamic accessLink;
@dynamic visible;
@dynamic createdAt;


+ (Friend *) dummy
{
    Friend *friend = [[Friend alloc] init];
    
    friend.name = @"Dummy";
    friend.createdAt = [NSDate date];
    
    return friend;
}

+ (void) generateSharedLinkToken
{
    
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@, %@", self.name, self.createdAt];
}

- (void) setVisible:(BOOL)_visible
{
    self.visible = _visible;
    
    // TODO: deactivate shared link temporarily
    
}

- (void) acceptInvitation
{
    //- If Friend has no invitee token then generate INVITEE_TOKEN for new shared link.
    //- Save invitee token to Friend and leave pending alone for now.
    //- PUT http://beacon.heroku.com/invitations/bx492/accept/INVITEE_TOKEN
    //- If server update success, set pending = 0.
}

- (void) denyInvitation
{
    //- PUT http://beacon.heroku.com/invitations/bx492/deny
    //- Delete Friend from DB.
}

- (void) handleInvitation:(NSString *)newInvitationCode
{
    //- Stub the friendship invitation request so that it responds immediately.
    //- Select * from friends where invitation_code = 'bx492'
    //- If no results, GET http://beacon.heroku.com/invitations/bx492
    //- If have result and pending = 0 then done.
    //- Response includes inviter's name and link share token.
    //- Add a Friend and set pending = 1 and invited = 1
}

#pragma mark -

+ (void) updateInvitationResponses
{
    //- When app loads, try to complete accepted friend invitations.
    //- select * from friends where invitee_token IS NOT NULL and pending = 1
    //- For each, PUT http://beacon.heroku.com/invitations/INVITER_TOKEN/accept/INVITEE_TOKEN
}

#pragma mark -

@end
