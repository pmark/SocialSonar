//
//  Friend.h
//  Beacon
//
//  Created by P. Mark Anderson on 11/21/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Friend : NSObject 
{
    NSString *name;
    NSString *inviterToken;
    NSString *inviteeToken;
    NSString *invitationCode;
    NSDate *createdAt;
    BOOL pending;
    BOOL invited;
    BOOL watching;
    BOOL cloaked;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *inviterToken;
@property (nonatomic, retain) NSString *inviteeToken;
@property (nonatomic, retain) NSString *invitationCode;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, assign) BOOL pending;
@property (nonatomic, assign) BOOL invited;
@property (nonatomic, assign) BOOL watching;
@property (nonatomic, assign) BOOL cloaked;

+ (Friend *) dummy;

@end
