/*
 
 */

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h> 
#import "Constants.h"

typedef enum {
    ConnectionStateDisconnected,
    ConnectionStateConnecting,
    ConnectionStateConnected
} ConnectionState;

typedef enum {
    PacketTypeOther = 0,
    PacketTypeStart = 1,
    PacketTypeReciprocalInvitation = 2,
    PacketTypeFinishInvitation = 3
} PacketType;


@interface PeerSessionManager : NSObject <GKSessionDelegate> {
	NSString *sessionID;
	GKSession *gkSession;
	NSString *currentConfPeerID;
	NSMutableArray *peerList;
	id lobbyDelegate;
	id handshakeDelegate;
    ConnectionState sessionState;
    BOOL initiator;
}

@property (nonatomic, readonly) NSString *currentConfPeerID;
@property (nonatomic, readonly) NSMutableArray *peerList;
@property (nonatomic, assign) id lobbyDelegate;
@property (nonatomic, assign) id handshakeDelegate;
@property (nonatomic, assign) ConnectionState sessionState;

- (void) setupSession;
- (void) connect:(NSString *)peerID;
- (BOOL) didAcceptInvitation;
- (void) didDeclineInvitation;
- (void) sendPacket:(NSData*)data ofType:(PacketType)type;
- (void) disconnectCurrentCall;
- (NSString *) displayNameForPeer:(NSString *)peerID;

@end

// Class extension for private methods.
@interface PeerSessionManager ()

- (BOOL) comparePeerID:(NSString*)peerID;
- (BOOL) isReadyToStart;
- (void) destroySession;
- (void) willTerminate:(NSNotification *)notification;
- (void) willResume:(NSNotification *)notification;

@end

@protocol SessionManagerLobbyDelegate

- (void) peerListDidChange:(PeerSessionManager *)session;
- (void) didReceiveInvitation:(PeerSessionManager *)session fromPeer:(NSString *)participantID;
- (void) invitationDidFail:(PeerSessionManager *)session fromPeer:(NSString *)participantID;

@end

@protocol PeerSessionManagerHandshakeDelegate

- (void) session:(PeerSessionManager *)session didConnectAsInitiator:(BOOL)shouldStart;
- (void) willDisconnect:(PeerSessionManager *)session;
- (void) session:(PeerSessionManager *)session didReceivePacket:(NSData*)data ofType:(PacketType)packetType;

@end

