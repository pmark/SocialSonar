/*
 Abstract: Lists available peers and handles the user interface related to connecting to
 a peer.
 */

#import <GameKit/GameKit.h> 
#import "PeerLobbyController.h"
#import "EmailController.h"
#import "CJSONDeserializer.h"
#import "SoSoAppDelegate.h"

@implementation PeerLobbyController
@synthesize manager;
@synthesize peerTableView;

#pragma mark View Controller Methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Add a Friend";
    
    manager = [[PeerSessionManager alloc] init]; 
    manager.lobbyDelegate = self;
    [manager setupSession];
    
	[self peerListDidChange:nil];
}

- (void)dealloc 
{
    manager.lobbyDelegate = nil;
    [manager release];
	[peerList release];
	[alertView release];
    self.peerTableView = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Geoloqi

- (void) composeEmailWithInvitation
{
    EmailController *email = [[EmailController alloc] initWithInvitationCode:invitationToken];
    
    if (email)
    {
        [self presentModalViewController:email animated:YES];
        
        [email release];    
    }    
}

- (LQHTTPRequestCallback)invitationCreatedCallback {
	if (invitationCreatedCallback) return invitationCreatedCallback;
    
	return invitationCreatedCallback = [^(NSError *error, NSString *responseBody) 
                                        {
        NSLog(@"Invitation created.");
        
        NSError *err = nil;
        NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:
                                                                                       NSUTF8StringEncoding]
                                                                                error:&err];
        if (!res || [res objectForKey:@"error"] != nil) 
        {
            NSLog(@"Error deserializing response (for invitation/create) \"%@\": %@", responseBody, err);
            [[Geoloqi sharedInstance] errorProcessingAPIRequest];
            return;
        }
        
        // Successful invitation creation.
        
        invitationToken = [[res objectForKey:@"invitation_token"] retain];        
        
        if ([invitationToken length] == 0)
        {
            [SoSoAppDelegate alertWithTitle:@"Sorry" message:@"Please try again later."];
        }
        else
        {
            [self composeEmailWithInvitation];
        }
        
        
    } copy];
}

- (void) createInvitation
{
    [[Geoloqi sharedInstance] createInvitation:[self invitationCreatedCallback]];
}


#pragma mark -
#pragma mark Opening Method
// Called when user selects a peer from the list or accepts a call invitation.
- (void) invitePeer:(NSString *)peerID
{
    [self createInvitation];        

    //	[self.navigationController pushViewController:gameScreen animated:YES];
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
//	[gameScreen release];
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *t = @"";
    
    switch (section) {
        case 0:
            t = @"Via Bluetooth / WiFi";
            break;
        case 1:
            t = @"Via Email";
            break;
        default:
            break;
    }
    
    return t;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *t = @"";
    
    switch (section) {
        case 0:
            if ([peerList count] == 0)
            {
                t = @"Tell your friends to run their Social Sonars with Bluetooth or WiFi on.";
            }
            else
            {
                t = @"Please select a friend.";
            }
            
            break;
        case 1:
            t = @"The email will contain instructions.";
            break;
        default:
            break;
    }
    
    return t;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    
    switch (section) {
        case 0:
            // Via Wireless (Bluetooth/WiFi).
            rowCount = [peerList count];
            
            if (rowCount == 0)
            {
                // Display a "scanning..." message
                rowCount = 1;
            }
            
            break;
            
        case 1:
            // Via Email.
            rowCount = 1;
            break;
            
        default:
            break;
    }

	return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	static NSString *TopLevelCellIdentifier = @"TopLevelCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TopLevelCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:TopLevelCellIdentifier] autorelease];
	}

    if (indexPath.section == 0)
    {
        // Wireless connection
        
        if ([peerList count] == 0)
        {
            // Scanning wireless space.

            cell.textLabel.text = @"Scanning for friends...";
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else
        {
            // Show nearby friends.
            
            cell.textLabel.text = [manager displayNameForPeer:[peerList objectAtIndex:indexPath.row]]; 
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
    }
    else
    {
        // Email
        
        cell.textLabel.text = @"Send Invitation";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	return cell;
}

#pragma mark Table View Delegate Methods

// The user selected a peer from the list to connect to.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        // Wireless
            
        if ([peerList count] == 0)
        {
            return;
        }
            
        NSString *peerID = [peerList objectAtIndex:[indexPath row]];
        [manager connect:peerID]; 
        [self invitePeer:peerID]; 
        
    }
    else
    {
        // Email

        [self createInvitation];        
    }
}

#pragma mark -
#pragma mark GameSessionLobbyDelegate Methods

- (void) peerListDidChange:(PeerSessionManager *)session;
{
    NSArray *tempList = peerList;
	peerList = [session.peerList copy];
    [tempList release];
	[self.peerTableView reloadData]; 
}

// Invitation dialog due to peer attempting to connect.
- (void) didReceiveInvitation:(PeerSessionManager *)session fromPeer:(NSString *)participantID;
{
	NSString *str = [NSString stringWithFormat:@"Incoming Invite from %@", participantID];
    if (alertView.visible) {
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
        [alertView release];
    }
	alertView = [[UIAlertView alloc] 
				 initWithTitle:str
				 message:@"Do you wish to accept?" 
				 delegate:self 
				 cancelButtonTitle:@"Decline" 
				 otherButtonTitles:nil];
	[alertView addButtonWithTitle:@"Accept"]; 
	[alertView show];
}

// Display an alert sheet indicating a failure to connect to the peer.
- (void) invitationDidFail:(PeerSessionManager *)session fromPeer:(NSString *)participantID
{
    NSString *str;
    if (alertView.visible) {
        // Peer cancelled invitation before it could be accepted/rejected
        // Close the invitation dialog before opening an error dialog
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
        [alertView release];
        str = [NSString stringWithFormat:@"%@ cancelled call", participantID]; 
    } else {
        // Peer rejected invitation or exited app.
        str = [NSString stringWithFormat:@"%@ declined your call", participantID]; 
    }
    
    alertView = [[UIAlertView alloc] initWithTitle:str message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark -
#pragma mark UIAlertViewDelegate Methods

// User has reacted to the dialog box and chosen accept or reject.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
        // User accepted.  Open the game screen and accept the connection.
        if ([manager didAcceptInvitation])
            [self invitePeer:manager.currentConfPeerID]; 
	} else {
        [manager didDeclineInvitation];
	}
}

@end