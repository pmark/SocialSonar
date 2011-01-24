//
//  EmailController.m
//  Beacon
//
//  Created by P. Mark Anderson on 2/7/10.
//  © Copyright, Bordertown Labs, LLC. All rights reserved.
//

#import "EmailController.h"
#import "SoSoAppDelegate.h"
#import "Geoloqi.h"

@implementation EmailController


- (void) dealloc 
{
    [invitationCode release];
    
    [super dealloc];
}

- (void) setup 
{
    self.mailComposeDelegate = self; 
    self.navigationBar.barStyle = UIBarStyleBlack; 
    self.navigationBar.translucent = NO;

    [self setSubject:@"Let's share locations"];

    NSString *body = [APP_DELEGATE html:@"invitation_email"];
        
    body = [body stringByReplacingOccurrencesOfString:@"{{CURRENT_LQUSER_SERVER}}" withString:[APP_DELEGATE apiServerHost]];
    body = [body stringByReplacingOccurrencesOfString:@"{{INVITATION_CODE}}" withString:invitationCode];

    [self setMessageBody:body isHTML:YES];
} 

- (id) initWithInvitationCode:(NSString*)code;
{
    if (![[self class] canSendMail])
    {
        [SoSoAppDelegate alertWithTitle:@"Mail setup required" message:@"Please add a mail account to this device."];
        return nil;
    }
        
    if (self = [super init]) 
    {    
        invitationCode = [code retain];        
        [self setup];
    }
    
    return self;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
}

#pragma mark -

- (void) close 
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{ 
    NSLog(@"[EC] mail composer finished");
    
	switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			break;
		case MFMailComposeResultFailed:
			break;
		default:
		{
            NSLog(@"[EC] Email failed");
		}
            
            break;
	}
    
    [self close];
}


@end
