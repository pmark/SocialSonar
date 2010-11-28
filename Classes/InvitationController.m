//
//  InvitationController.m
//  Beacon
//
//  Created by P. Mark Anderson on 11/27/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

#import "InvitationController.h"


@implementation InvitationController


- (void)dealloc {
    [webView release];
    webView = nil;
    [invitationCode release];
    
    [super dealloc];
}

- (id)initWithInvitationCode:(NSString*)code
{
    self = [super init];
    
    if (self) 
    {
        invitationCode = [code retain];
    }

    return self;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    [webView loadHTMLString:invitationCode baseURL:nil];

}

- (IBAction) accept
{
    [self dismissModalViewControllerAnimated:YES];
    
    // TODO: more stuff
}

- (IBAction) deny
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
