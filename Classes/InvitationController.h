//
//  InvitationController.h
//  Beacon
//
//  Created by P. Mark Anderson on 11/27/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Geoloqi.h"

@interface InvitationController : UIViewController 
{
    IBOutlet UIWebView *webView;
    NSDictionary *invitation;
    GLHTTPRequestCallback claimInvitationBlock;
    GLHTTPRequestCallback confirmInvitationBlock;
    GLHTTPRequestCallback invitationCreatedCallback;
    NSDictionary *reciprocalInvitation;
    NSString *host;
}

@property (nonatomic, retain) NSDictionary *reciprocalInvitation;
@property (nonatomic, retain) NSString *host;

- (id)initWithInvitation:(NSDictionary*)invitation;
- (IBAction) accept;
- (IBAction) deny;

@end
