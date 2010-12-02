//
//  InvitationController.m
//  Beacon
//
//  Created by P. Mark Anderson on 11/27/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

#import "InvitationController.h"
#import "CJSONDeserializer.h"
#import "BeaconAppDelegate.h"
#import "EmailController.h"
#import "Friend.h"

@implementation InvitationController

@synthesize reciprocalInvitation;
@synthesize host;

- (void)dealloc {
    [webView release];
    webView = nil;
    [invitation release];
    [reciprocalInvitation release];
    [host release];
    
    [super dealloc];
}

- (id)initWithInvitation:(NSDictionary*)_invitation
{
    self = [super init];
    
    if (self) 
    {
        invitation = [_invitation retain];
        self.host = APP_DELEGATE.invitationHost;
    }

    return self;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    [webView loadHTMLString:[invitation description] baseURL:nil];

}

- (void) composeReciprocalInvitationEmail
{

    NSString *invitationToken = [reciprocalInvitation objectForKey:@"invitation_token"];

    EmailController *email = [[EmailController alloc] initWithInvitationCode:invitationToken];
    
    if (email)
    {
        UIViewController *parent = self.parentViewController;
        [self dismissModalViewControllerAnimated:NO];
        
        email.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [parent presentModalViewController:email animated:NO];
        
        [email release];    
    }
}

- (void) createFriend:(NSDictionary *)data withAccessToken:(NSString *)accessToken
{
    NSLog(@"Creating friend with access token %@: %@", accessToken, data);
    
	Friend *friend = (Friend *)[NSEntityDescription insertNewObjectForEntityForName:@"Friend" 
                                                             inManagedObjectContext:MOCONTEXT];
	
	[friend setName:[data objectForKey:@"name"]];
    [friend setInvitationToken:[data objectForKey:@"invitation_token"]];
    [friend setServerURL:[data objectForKey:@"invitation_server"]];
    [friend setAccessToken:accessToken];
	[friend setCreatedAt:[NSDate date]];
	
	// Commit the change.
	NSError *error;
    
	if (![MOCONTEXT save:&error]) 
    {
		NSLog(@"ERROR creating friend: %@", [error localizedDescription]);        
	}    
}

- (GLHTTPRequestCallback)claimInvitationBlock 
{
	if (claimInvitationBlock) return claimInvitationBlock;
    
	return claimInvitationBlock = [^(NSError *error, NSString *responseBody) 
           {
               NSLog(@"Invitation claimed.");
               
               NSError *err = nil;
               NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:
                                                                                              NSUTF8StringEncoding]
                                                                                       error:&err];
               if (!res || [res objectForKey:@"error"] != nil) 
               {
                   NSLog(@"Error deserializing response (for invitation/claim) \"%@\": %@", responseBody, err);
                   [[Geoloqi sharedInstance] errorProcessingAPIRequest];
                   return;
               }
               
               self.reciprocalInvitation = [res retain];
               
               NSLog(@"Reciprocal invitation: %@", reciprocalInvitation);
               
               [self createFriend:invitation withAccessToken:nil];
                
               [self composeReciprocalInvitationEmail];
               
               
           } copy];
}

- (GLHTTPRequestCallback)confirmInvitationBlock {
	if (confirmInvitationBlock) return confirmInvitationBlock;
    
	return confirmInvitationBlock = [^(NSError *error, NSString *responseBody) 
             {
                 NSLog(@"Invitation confirmed.");
                 
                 NSError *err = nil;
                 NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:
                                                                                                NSUTF8StringEncoding]
                                                                                         error:&err];
                 if (!res || [res objectForKey:@"error"] != nil) 
                 {
                     NSLog(@"Error deserializing response (for invitation/confirm) \"%@\": %@", responseBody, err);
                     [[Geoloqi sharedInstance] errorProcessingAPIRequest];
                     return;
                 }
                 
                 [self createFriend:invitation withAccessToken:[res objectForKey:@"access_token"]];
                                  
                 [self dismissModalViewControllerAnimated:YES];        

             } copy];
}

- (IBAction) accept
{    
    NSLog(@"Claiming invitation for host %@: %@", host, invitation);
    
    NSString *invitationToken = [invitation objectForKey:@"invitation_token"];
    
    BOOL alreadyClaimed = [[invitation objectForKey:@"invitation_confirmed"] isEqualToString:@"1"];
    
    if (alreadyClaimed)
    {
        [[Geoloqi sharedInstance] confirmInvitation:invitationToken 
                                               host:self.host
                                           callback:[self confirmInvitationBlock]];
    }
    else 
    {
        [[Geoloqi sharedInstance] claimInvitation:invitationToken 
                                             host:self.host
                                         callback:[self claimInvitationBlock]];
    }
    
}

- (IBAction) confirm
{    
    NSLog(@"Confirming invitation: %@", invitation);
    
    NSString *invitationToken = [invitation objectForKey:@"invitation_token"];
    
    [[Geoloqi sharedInstance] confirmInvitation:invitationToken 
                                           host:self.host
                                       callback:[self confirmInvitationBlock]];
    
}

- (IBAction) deny
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
