/*
 Abstract: Lists available peers and handles the user interface related to connecting to
 a peer.
 */

#import <GameKit/GameKit.h> 
#import "PeerLobbyController.h"
#import "EmailController.h"
#import "CJSONDeserializer.h"
#import "SoSoAppDelegate.h"

typedef struct {
    NSString *invitationToken;
} Packet;

@implementation PeerLobbyController
@synthesize manager;
@synthesize peerTableView;
@synthesize invitedPeer;

#pragma mark View Controller Methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Add a Friend";
    
    manager = [[PeerSessionManager alloc] init]; 
    manager.lobbyDelegate = self;
    manager.handshakeDelegate = self;

    [manager setupSession];
    
	[self peerListDidChange:nil];
    
    invitationStatusLabel.text = @"";
    receivedInvitationToken = nil;
    
}

- (void)dealloc 
{
    manager.lobbyDelegate = nil;
    [manager release];
	[peerList release];
	[alertView release];
    self.peerTableView = nil;
    
    [spinner release];
    spinner = nil;    
    [blocker release];
    blocker = nil;
    [blockerContainer release];
    blockerContainer = nil;
    [invitationStatusLabel release];
    invitationStatusLabel = nil;    
    
    self.invitedPeer = nil;
    [receivedInvitationToken release];
    
    [super dealloc];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setBlockerHidden:YES animated:NO];
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

- (void) beginWirelessInvitation
{
    invitationStatusLabel.text = @"Waiting for friend's response";

    NSLog(@"Requesting connection to '%@'", invitedPeer);
    [manager connect:invitedPeer]; 

}

- (void) sendInvitationTokenToPeer
{
    invitationStatusLabel.text = @"???";
    
//    NSLog(@"Sending invitation to peer '%@'", invitedPeer);
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
            
            [self presentServerErrorAlert];
            
            [self setBlockerHidden:YES animated:YES];
            
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
            // Successful invitation generation.
            
            switch (invitationType) {
                case InvitationTypeEmail:
                    [self composeEmailWithInvitation];
                    break;
                    
                case InvitationTypeWireless:
                    [self beginWirelessInvitation];
                    break;
                    
                default:
                    break;
            }
        }
        
        
    } copy];
}

- (void) blockerAnimationDidStop
{
    if (blockerContainer.alpha < 0.1)
    {
        blockerContainer.hidden = YES;
    }
}

- (void) setBlockerHidden:(BOOL)hide animated:(BOOL)animated
{
    if (hide == blockerContainer.hidden)
        return;
    
    CGFloat alpha = (hide ? 0.0 : 1.0);

    if (!hide)
    {
        // Show the blockerContainer right away,
        // but delay hiding it until after the animation ends.
        
        blockerContainer.hidden = NO;
        blockerContainer.alpha = 1.0;
    }
    
    if (!animated)
    {
        blockerContainer.hidden = hide;
        blockerContainer.alpha = alpha;
    }
    else
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDidStopSelector:@selector(blockerAnimationDidStop)];
        
        blockerContainer.alpha = alpha;
        
        [UIView commitAnimations];
    }        
    
#if 0 
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:INFINITY];
    
    spinner.transform = CGAffineTransformMakeRotation(180);
    
    [UIView commitAnimations];
#else    
    if (hide)
    {
        [spinner.layer removeAllAnimations];
    }
    else
    {
        CABasicAnimation *fullRotation;
        fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        fullRotation.fromValue = [NSNumber numberWithFloat:0];
        fullRotation.toValue = [NSNumber numberWithFloat:(-(360*M_PI)/180)];
        fullRotation.duration = 1.66;
        fullRotation.repeatCount = INFINITY;
        
        [spinner.layer addAnimation:fullRotation forKey:@"360"];
    }
#endif
    
}

- (void) createGeoloqiInvitation
{
    [self setBlockerHidden:NO animated:YES];
    
    invitationStatusLabel.text = @"Creating invitation";

#if 1

    NSLog(@"\n\n NOT USING GEOLOQI, FOR TESTING\n\n");
    invitationToken = @"BOGUS";    
    [self beginWirelessInvitation];

#else
    
    [[Geoloqi sharedInstance] createInvitation:[self invitationCreatedCallback]];
    
#endif
    
}


#pragma mark -
#pragma mark Opening Method
// Called when user selects a peer from the list or accepts an invitation.
- (void) invitePeer:(NSString *)peerID
{
    invitationType = InvitationTypeWireless;
    
    self.invitedPeer = peerID;

    [self createGeoloqiInvitation];        
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
        // Wireless
            
        if ([peerList count] == 0)
        {
            return;
        }
            
        NSString *peerID = [peerList objectAtIndex:[indexPath row]];

        invitationStatusLabel.text = @"Connecting";
        
        [self invitePeer:peerID]; 
        
    }
    else
    {
        // Email

        invitationType = InvitationTypeEmail;

        [self createGeoloqiInvitation];        
    }
}

#pragma mark -
#pragma mark PeerSessionLobbyDelegate Methods

- (void) peerListDidChange:(PeerSessionManager *)session;
{
    NSArray *tempList = peerList;    
    
	peerList = [session.peerList copy];
    
    // Remove duplicates.
    
    [tempList release];
	[self.peerTableView reloadData]; 
}

// Invitation dialog due to peer attempting to connect.
- (void) didReceiveInvitation:(PeerSessionManager *)session fromPeer:(NSString *)participantID;
{
	NSString *str = [NSString stringWithFormat:@"Incoming invite from %@", participantID];

    if (alertView.visible) 
    {
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
        [alertView release];
    }
    
    [self setBlockerHidden:NO animated:YES];
    
	alertView = [[UIAlertView alloc] 
				 initWithTitle:str
				 message:@"Would you like to share your location with this person?" 
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
    if (alertView.visible) 
    {
        // Peer cancelled invitation before it could be accepted/rejected
        // Close the invitation dialog before opening an error dialog
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
        [alertView release];
        str = [NSString stringWithFormat:@"%@ cancelled.", participantID]; 
    } 
    else 
    {

        // Peer rejected invitation or exited app.
        str = [NSString stringWithFormat:@"%@ did not accept your invitation.", participantID]; 
        
    }
    
    alertView = [[UIAlertView alloc] initWithTitle:str message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    [self setBlockerHidden:YES animated:YES];
}

#pragma mark -
#pragma mark UIAlertViewDelegate Methods

// Invited user has chosen to accept or reject the invitation.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Dismissing alert. GKSession state: %i", manager.sessionState);
    
    if (manager.sessionState != ConnectionStateDisconnected)
    {
        if (buttonIndex == 1) 
        {
            // User accepted.  Accept the connection.
            
            NSLog(@"Accepting invitation...");
            
            if ([manager didAcceptInvitation])
            {
                
                [self beginWirelessInvitation];
                
                // Send invitation code to peer
                
                
            }
            
        } 
        else 
        {
            NSLog(@"Declining invitation...");

            invitationStatusLabel.text = @"";
            [self setBlockerHidden:YES animated:YES];
            
            [manager didDeclineInvitation];        
        }
    }
    
}

#pragma mark -
#pragma mark SessionManagerHandshakeDelegate Methods

- (void) session:(PeerSessionManager *)session didConnectAsInitiator:(BOOL)shouldStart
{
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	
    invitationStatusLabel.text = @"Connected"; 
    
    if (shouldStart) 
    {
        
        NSLog(@"Session started. Sending start packet.");
        
        [self sendPacket:PacketTypeStart];
        
    }
    else
    {
        NSLog(@"Session started by peer.");
    }
}

// If hit end call or the call failed or timed out, clear the state and go back a screen.
- (void) willDisconnect:(PeerSessionManager *)session
{
    invitationStatusLabel.text = @"Disconnected";

    self.invitedPeer = nil;
    
    [self setBlockerHidden:YES animated:YES];
    
//    rocketStart = FALSE;
//    playerTalking = FALSE;
//    enemyTalking = FALSE;

//   	manager.handshakeDelegate = nil;
//	[manager release];
//    manager = nil;
}

// The GKSession got a packet and sent it to the game, so parse it and update state.
- (void) session:(PeerSessionManager *)session didReceivePacket:(NSData*)data ofType:(PacketType)packetType
{
    Packet incoming;

    if ([data length] == sizeof(Packet)) 
    {
        [data getBytes:&incoming length:sizeof(Packet)];
        
        switch (packetType) 
        {
            case PacketTypeStart:
                // The inviter sent a token.
                
                NSLog(@"Received invitation token: %@", incoming.invitationToken);
                receivedInvitationToken = [incoming.invitationToken retain];
                
                break;

            case PacketTypeEndTalking:
                // The other player is ready to play again.
                break;
            default:
                break;
        }
    }
}

#pragma mark -
#pragma mark Game Network Logic

// Send the same information each time, just with a different header
-(void) sendPacket:(PacketType)packetType
{
    Packet outgoing;

    if (packetType == PacketTypeStart)
    {
        NSLog(@"Preparing packet with invitationToken: %@", invitationToken);
        
        outgoing.invitationToken = invitationToken;
        
    }
    
    NSData *packet = [[NSData alloc] initWithBytes:&outgoing length:sizeof(Packet)];
    
    [manager sendPacket:packet ofType:packetType];
    
    [packet release];
}

- (void) presentServerErrorAlert
{
    [SoSoAppDelegate alertWithTitle:@"Technical Difficulties" 
                            message:@"Sorry, but there was a problem communicating with the server. Please make sure you're connected to the internet and try again later."];
    
    
}

@end
