/*
 
 */

#import <AudioToolbox/AudioToolbox.h>
#import "PeerSessionManager.h"

#define SESSION_ID @"gkrocket"

@implementation PeerSessionManager
@synthesize currentConfPeerID;
@synthesize peerList;
@synthesize lobbyDelegate;
@synthesize gameDelegate;

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
	// GKSession will default to using the device name as the display name
	gkSession = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModePeer];
	gkSession.delegate = self; 
	[gkSession setDataReceiveHandler:self withContext:nil]; 
	gkSession.available = YES;
    sessionState = ConnectionStateDisconnected;
    [lobbyDelegate peerListDidChange:self];
}

// Initiates a GKSession connection to a selected peer.
-(void) connect:(NSString *) peerID
{
	[gkSession connectToPeer:peerID withTimeout:10.0];
    currentConfPeerID = [peerID retain];
    sessionState = ConnectionStateConnecting;
}

// Called from GameLobbyController if the user accepts the invitation alertView
-(BOOL) didAcceptInvitation
{
    NSError *error = nil;
    if (![gkSession acceptConnectionFromPeer:currentConfPeerID error:&error]) {
        NSLog(@"%@",[error localizedDescription]);
    }
    
    return (gameDelegate == nil);
}

// Called from GameLobbyController if the user declines the invitation alertView
-(void) didDeclineInvitation
{
    // Deny the peer.
    if (sessionState != ConnectionStateDisconnected) {
        [gkSession denyConnectionFromPeer:currentConfPeerID];
		[currentConfPeerID release];
        currentConfPeerID = nil;
        sessionState = ConnectionStateDisconnected;
    }
    // Go back to the lobby if the game screen is open.
    [gameDelegate willDisconnect:self];
}

-(BOOL) comparePeerID:(NSString*)peerID
{
    return [peerID compare:gkSession.peerID] == NSOrderedAscending;
}

// Called to check if the session is ready to start a voice chat.
-(BOOL) isReadyToStart
{
    return sessionState == ConnectionStateConnected;
}

// When the voice chat starts, tell the game it can begin.
-(void) sessionDidStart
{
    [gameDelegate session:self didConnectAsInitiator:![self comparePeerID:currentConfPeerID]];
}

// Called by RocketController and VoiceManager to send data to the peer
-(void) sendPacket:(NSData*)data ofType:(PacketType)type
{
    NSMutableData * newPacket = [NSMutableData dataWithCapacity:([data length]+sizeof(uint32_t))];
    // Both game and voice data is prefixed with the PacketType so the peer knows where to send it.
    uint32_t swappedType = CFSwapInt32HostToBig((uint32_t)type);
    [newPacket appendBytes:&swappedType length:sizeof(uint32_t)];
    [newPacket appendData:data];
    NSError *error;
  	if (![gkSession sendData:newPacket toPeers:[NSArray arrayWithObject:currentConfPeerID] withDataMode:GKSendDataReliable error:&error]) {
        NSLog(@"%@",[error localizedDescription]);
    }
}

// Clear the connection states in the event of leaving a call or error.
-(void) disconnectCurrentCall
{	
    [gameDelegate willDisconnect:self];

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
    [peerList removeAllObjects];
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
    if (sessionState == ConnectionStateDisconnected) {
        currentConfPeerID = [peerID retain];
        sessionState = ConnectionStateConnecting;
        [lobbyDelegate didReceiveInvitation:self fromPeer:[gkSession displayNameForPeer:peerID]];
    } else {
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

// React to some activity from other peers on the network.
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	switch (state) { 
		case GKPeerStateAvailable:
            // A peer became available by starting app, exiting settings, or ending a call.
			if (![peerList containsObject:peerID]) {
				[peerList addObject:peerID]; 
			}
 			[lobbyDelegate peerListDidChange:self]; 
			break;
		case GKPeerStateUnavailable:
            // Peer unavailable due to joining a call, leaving app, or entering settings.
            [peerList removeObject:peerID]; 
            [lobbyDelegate peerListDidChange:self]; 
			break;
		case GKPeerStateConnected:
            // Connection was accepted.
            currentConfPeerID = [peerID retain];
            gkSession.available = NO;

            sessionState = ConnectionStateConnected;

            // Compare the IDs to decide which device will invite the other to a voice chat.
            if([self comparePeerID:peerID]) {
            }
            
			break;				
		case GKPeerStateDisconnected:
            // The call ended either manually or due to failure somewhere.
            [self disconnectCurrentCall];
            [peerList removeObject:peerID]; 
            [lobbyDelegate peerListDidChange:self];
			break;
        case GKPeerStateConnecting:
            // Peer is attempting to connect to the session.
            break;
		default:
			break;
	}
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
        if (header == PacketTypeVoice) {
        } else {
            [gameDelegate session:self didReceivePacket:payload ofType:header];
        }
    }
}

- (NSString *) displayNameForPeer:(NSString *)peerID
{
	return [gkSession displayNameForPeer:peerID];
}


@end

