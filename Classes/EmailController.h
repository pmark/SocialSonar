//
//  EmailController.h
//  Beacon
//
//  Created by P. Mark Anderson on 2/7/10.
//  © Copyright, Bordertown Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface EmailController : MFMailComposeViewController <MFMailComposeViewControllerDelegate> 
{
    NSString *invitationCode;
}

- (id) initWithInvitationCode:(NSString*)code;

@end
