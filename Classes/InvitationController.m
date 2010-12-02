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

- (GLHTTPRequestCallback)acceptInvitationBlock {
	if (acceptInvitationBlock) return acceptInvitationBlock;
    
	return acceptInvitationBlock = [^(NSError *error, NSString *responseBody) 
            {
                NSLog(@"Invitation accepted.");
                
                NSError *err = nil;
                NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:
                                                                                               NSUTF8StringEncoding]
                                                                                        error:&err];
                if (!res || [res objectForKey:@"error"] != nil) 
                {
                    NSLog(@"Error deserializing response (for invitations/create) \"%@\": %@", responseBody, err);
                    [[Geoloqi sharedInstance] errorProcessingAPIRequest];
                    return;
                }
                
                self.reciprocalInvitation = [res retain];
                
                NSLog(@"Reciprocal invitation: %@", reciprocalInvitation);
                
            } copy];
}

- (IBAction) accept
{    
    NSLog(@"Accepting invitation: %@", invitation);
    
    NSString *invitationToken = [invitation objectForKey:@"invitation_token"];
    
    NSString *url = [APP_DELEGATE apiServerURL];
    
    [[Geoloqi sharedInstance] acceptInvitationAtServer:url 
                                       invitationToken:invitationToken 
                                              callback:[self acceptInvitationBlock]];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) deny
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
