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

@implementation InvitationController

@synthesize reciprocalInvitation;

- (void)dealloc {
    [webView release];
    webView = nil;
    [invitation release];
    [reciprocalInvitation release];
    
    [super dealloc];
}

- (id)initWithInvitation:(NSDictionary*)_invitation
{
    self = [super init];
    
    if (self) 
    {
        invitation = [_invitation retain];
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
    
    UIViewController *parent = self.parentViewController;
    [self dismissModalViewControllerAnimated:NO];
    
    email.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [parent presentModalViewController:email animated:NO];
    
    [email release];    
}

- (GLHTTPRequestCallback)claimInvitationBlock {
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
                 
                 [self dismissModalViewControllerAnimated:YES];        

             } copy];
}

- (IBAction) accept
{    
    NSLog(@"Claiming invitation: %@", invitation);
    
    NSString *url = [APP_DELEGATE apiServerURL];
    
    NSString *invitationToken = [invitation objectForKey:@"invitation_token"];
    
    BOOL alreadyClaimed = [[invitation objectForKey:@"invitation_confirmed"] isEqualToString:@"1"];
    
    if (alreadyClaimed)
    {
        [[Geoloqi sharedInstance] confirmInvitationAtServer:url 
                                          invitationToken:invitationToken 
                                                 callback:[self confirmInvitationBlock]];
    }
    else 
    {
        [[Geoloqi sharedInstance] claimInvitationAtServer:url 
                                          invitationToken:invitationToken 
                                                 callback:[self claimInvitationBlock]];
    }
    
}

- (IBAction) confirm
{    
    NSLog(@"Confirming invitation: %@", invitation);
    
    NSString *invitationToken = [invitation objectForKey:@"invitation_token"];
    
    NSString *url = [APP_DELEGATE apiServerURL];
    
    [[Geoloqi sharedInstance] confirmInvitationAtServer:url 
                                      invitationToken:invitationToken 
                                             callback:[self confirmInvitationBlock]];
    
}

- (IBAction) deny
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
