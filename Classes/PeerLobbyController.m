/*
 Abstract: Lists available peers and handles the user interface related to connecting to
 a peer.
 */

#import "PeerLobbyController.h"
//#import "RocketController.h"
#import <GameKit/GameKit.h> 

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
#pragma mark Opening Method
// Called when user selects a peer from the list or accepts a call invitation.
- (void) invitePeer:(NSString *)peerID
{
//	[self.navigationController pushViewController:gameScreen animated:YES];
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
//	[gameScreen release];
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [peerList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	static NSString *TopLevelCellIdentifier = @"TopLevelCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TopLevelCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero
                                       reuseIdentifier:TopLevelCellIdentifier] autorelease];
	}

	NSUInteger row = [indexPath row];
	
	cell.textLabel.text = [manager displayNameForPeer:[peerList objectAtIndex:row]]; 
	return cell;
}

#pragma mark Table View Delegate Methods

// The user selected a peer from the list to connect to.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[manager connect:[peerList objectAtIndex:[indexPath row]]]; 
	[self invitePeer:[peerList objectAtIndex:[indexPath row]]]; 
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
