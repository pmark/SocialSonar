/*
 
 */

#import <AudioToolbox/AudioToolbox.h>
#import "PeerSessionManager.h"
#import "SoSoAppDelegate.h"

#define SESSION_ID @"social_sonar"

@implementation PeerSessionManager
@synthesize currentConfPeerID;
@synthesize peerList;
@synthesize lobbyDelegate;
@synthesize handshakeDelegate;
@synthesize sessionState;

#pragma mark -
#pragma mark NSObject Methods

- (id)init 
{
	if (self = [super init]) {
        
        // Peers need to have the same sessionID set on their GKSession to see each other.
		sessionID = SESSION_ID; 
        
		peerList = [[NSMutableArray alloc] init];
        
        // Set up starting/stopping session on application hiding/terminating
        [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(willTerminate:)
                                              name:UIApplicationWillTerminateNotification
                                              object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(willTerminate:)
                                              name:UIApplicationWillResignActiveNotification
                                              object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(willResume:)
                                              name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
        
	}
	return self;  
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (gkSession) [self destroySession];
	gkSession = nil;
	sessionID = nil; 
	[peerList release]; 
    
    [super dealloc];
}

#pragma mark -
#pragma mark Session logic

// Creates a GKSession and advertises availability to Peers
- (void) setupSession
{
    //NSTimeInterval tstamp = [NSDate timeIntervalSinceReferenceDate];
    NSString *udid = [[UIDevice currentDevice] uniqueIdentifier];

    NSString *displayName = [NSString stringWithFormat:@"%@%@%@", 
                             APP_DELEGATE.nickname, PEER_NAME_DIVIDER, udid];
                             
	// GKSession will default to using the device name as the display name
	gkSession = [[GKSession alloc] initWithSessionID:sessionID 
                                         displayName:displayName
                                         sessionMode:GKSessionModePeer];
	gkSession.delegate = self; 
	[gkSession setDataReceiveHandler:self withContext:nil]; 
	gkSession.available = YES;
    sessionState = ConnectionStateDisconnected;
    [lobbyDelegate peerListDidChange:self];
}

// Initiates a GKSession connection to a selected peer.
-(void) connect:(NSString *) peerID
{
    initiator = YES;
	[gkSession connectToPeer:peerID withTimeout:10.0];
    currentConfPeerID = [peerID retain];
    sessionState = ConnectionStateConnecting;
}

// Called from PeerLobbyController if the user accepts the invitation alertView
-(BOOL) didAcceptInvitation
{
    NSError *error = nil;
    
    if (![gkSession acceptConnectionFromPeer:currentConfPeerID error:&error]) 
    {
        NSLog(@"ERROR in didAcceptInvitation: %@", [error localizedDescription]);
    }
    else
    {
        NSLog(@"Invitation accepted!");        
    }
    
    return (handshakeDelegate == nil);
}

// Called from PeerLobbyController if the user declines the invitation alertView
-(void) didDeclineInvitation
{
    NSLog(@"Invitation declined.");

    // Deny the peer.
    if (sessionState != ConnectionStateDisconnected) 
    {
        NSLog(@"Denying peer connection from '%@'", currentConfPeerID);

        [gkSession denyConnectionFromPeer:currentConfPeerID];
		[currentConfPeerID release];
        currentConfPeerID = nil;

        sessionState = ConnectionStateDisconnected;
    }
    
    // Go back to the lobby if the game screen is open.
    [handshakeDelegate willDisconnect:self];
}

-(BOOL) comparePeerID:(NSString*)peerID
{
    BOOL ascending = ([peerID compare:gkSession.peerID] == NSOrderedAscending);
    
    NSLog(@"Comparing my session's peer ID (%@) to other peer (%@): %i", gkSession.peerID, peerID, ascending);
    
    return ascending;
}

-(BOOL) isReadyToStart
{
    return sessionState == ConnectionStateConnected;
}

-(void) sessionDidStart
{
//    BOOL isInitiator = [self comparePeerID:currentConfPeerID];
    NSLog(@"Session started %@.", (initiator ? @"as initiator" : @"as invitee"));
    [handshakeDelegate session:self didConnectAsInitiator:initiator];
}

//
// Called by PeerLobbyController to send data to the peer.
//
-(void) sendPacket:(NSData*)data ofType:(PacketType)type
{
    NSMutableData *newPacket = [NSMutableData dataWithCapacity:([data length] + sizeof(uint32_t))];
    
    // Both game and voice data is prefixed with the PacketType so the peer knows where to send it.
    
    uint32_t swappedType = CFSwapInt32HostToBig((uint32_t)type);
    [newPacket appendBytes:&swappedType length:sizeof(uint32_t)];
    [newPacket appendData:data];
    
    NSError *error;

    NSLog(@"Sending packet of type %i to %@", type, currentConfPeerID);
    
    if ([currentConfPeerID length] == 0)
    {
        NSLog(@"ERROR: Lost peer");
        [handshakeDelegate willDisconnect:self];
        return;
    }
    
  	if (![gkSession sendData:newPacket 
                     toPeers:[NSArray arrayWithObject:currentConfPeerID] 
                withDataMode:GKSendDataReliable error:&error]) 
    {
        NSLog(@"%@",[error localizedDescription]);
    }
}

// Clear the connection states in the event of leaving a call or error.
-(void) disconnectCurrentCall
{	
    [handshakeDelegate willDisconnect:self];

    if (sessionState != ConnectionStateDisconnected) {

        if(sessionState == ConnectionStateConnected) {		
        }

        // Don't leave a peer hangin'
        if (sessionState == ConnectionStateConnecting) {
            [gkSession cancelConnectToPeer:currentConfPeerID];
        }

        [gkSession disconnectFromAllPeers];
        gkSession.available = YES;
        sessionState = ConnectionStateDisconnected;

		[currentConfPeerID release];
        currentConfPeerID = nil;
    }
}

// Application is exiting or becoming inactive, end the session.
- (void)destroySession
{
    [self disconnectCurrentCall];
	gkSession.delegate = nil;
    
	[gkSession setDataReceiveHandler:nil withContext:nil];
	[gkSession release];

    // TODO: Fix this crash.
//    if (peerList)
//        [peerList removeAllObjects];
}

// Called when notified the application is exiting or becoming inactive.
- (void)willTerminate:(NSNotification *)notification
{
    [self destroySession];
}

// Called after the app comes back from being hidden by something like a phone call.
- (void)willResume:(NSNotification *)notification
{
    [self setupSession];
}

#pragma mark -
#pragma mark GKSessionDelegate Methods and Helpers

// Received an invitation.  If we aren't already connected to someone, open the invitation dialog.
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    if (sessionState == ConnectionStateDisconnected) 
    {
        currentConfPeerID = [peerID retain];
        
        sessionState = ConnectionStateConnecting;

        [lobbyDelegate didReceiveInvitation:self 
                                   fromPeer:[gkSession displayNameForPeer:peerID]];
        
    } 
    else 
    {
        [gkSession denyConnectionFromPeer:peerID];
    }
}

// Unable to connect to a session with the peer, due to rejection or exiting the app
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    NSLog(@"%@",[error localizedDescription]);
    if (sessionState != ConnectionStateDisconnected) {
        [lobbyDelegate invitationDidFail:self fromPeer:[gkSession displayNameForPeer:peerID]];
        // Make self available for a new connection.
		[currentConfPeerID release];
        currentConfPeerID = nil;
        gkSession.available = YES;
        sessionState = ConnectionStateDisconnected;
    }
}

// The running session ended, potentially due to network failure.
- (void)session:(GKSession *)session didFailWithError:(NSError*)error
{
    NSLog(@"%@",[error localizedDescription]);
    [self disconnectCurrentCall];
}

- (void)prunePeerList
{
    NSMutableDictionary *prunedPeers = [NSMutableDictionary dictionary];

    NSString *udid = [[[UIDevice currentDevice] uniqueIdentifier] substringToIndex:20];

    for (NSString *peerID in peerList)
    {
        NSString *displayName = [self displayNameForPeer:peerID];
        
        //NSLog(@"Checking if %@ has UDID %@", displayName, udid);

        BOOL containsMyUDID = ([displayName rangeOfString:udid].location != NSNotFound);
        
        if ([displayName length] == 0 || containsMyUDID)
            continue;
        
        [prunedPeers setObject:peerID forKey:displayName];
    }
    
//    NSLog(@"Old peerList: %@", peerList);
    
    [peerList removeAllObjects];
    [peerList addObjectsFromArray:[prunedPeers allValues]];

//    NSLog(@"Pruned peerList: %@\n\n", peerList);
    
}

// React to some activity from other peers on the network.
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    NSLog(@"'%@' peer's state is now %i", peerID, state);
    
	switch (state) 
    { 
		case GKPeerStateAvailable:
            
            // A peer became available by starting app, exiting settings, or ending a call.
			
            if (![peerList containsObject:peerID]) 
            {
                NSLog(@"Adding peer '%@'", peerID);
				[peerList addObject:peerID]; 
			}
            
            [self prunePeerList];
            
 			[lobbyDelegate peerListDidChange:self]; 
            
			break;
            
		case GKPeerStateUnavailable:
            
            // Peer unavailable due to joining a call, leaving app, or entering settings.
            [peerList removeObject:peerID]; 
            
            if ([currentConfPeerID isEqualToString:peerID])
            {
                [currentConfPeerID release];
            }

            [lobbyDelegate peerListDidChange:self]; 
            
			break;
            
		case GKPeerStateConnected:

            // Connection was accepted.
            currentConfPeerID = [peerID retain];
            gkSession.available = NO;

            sessionState = ConnectionStateConnected;

            NSLog(@"Connected to peer %@", peerID);
            [self sessionDidStart];
            
			break;				
            
		case GKPeerStateDisconnected:
            // The call ended either manually or due to failure somewhere.
            
            [self disconnectCurrentCall];
            
            [peerList removeObject:peerID]; 
            
            [lobbyDelegate peerListDidChange:self];
			break;
            
        case GKPeerStateConnecting:
            // Peer is attempting to connect to the session.
            NSLog(@"\n\nPeer connecting...\n\n");
            break;
            
		default:
			break;
	}

//    NSLog(@"peerList: %@", [peerList componentsJoinedByString:@", "]);    
}

// Called when voice or game data is received over the network from the peer
- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
    PacketType header;
    uint32_t swappedHeader;
    if ([data length] >= sizeof(uint32_t)) {    
        [data getBytes:&swappedHeader length:sizeof(uint32_t)];
        header = (PacketType)CFSwapInt32BigToHost(swappedHeader);
        NSRange payloadRange = {sizeof(uint32_t), [data length]-sizeof(uint32_t)};
        NSData* payload = [data subdataWithRange:payloadRange];
        
        // Check the header to see if this is a voice or a game packet
    
        [handshakeDelegate session:self didReceivePacket:payload ofType:header];

    }
}

- (NSString *) displayNameForPeer:(NSString *)peerID
{
	return [gkSession displayNameForPeer:peerID];
}

#pragma mark -

@end

