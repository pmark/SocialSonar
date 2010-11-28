//
//  InvitationController.h
//  Beacon
//
//  Created by P. Mark Anderson on 11/27/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InvitationController : UIViewController 
{
    IBOutlet UIWebView *webView;
    NSString *invitationCode;
}

- (id)initWithInvitationCode:(NSString*)code;
- (IBAction) accept;
- (IBAction) deny;

@end
