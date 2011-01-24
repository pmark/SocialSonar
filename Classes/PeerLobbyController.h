/*
 Abstract: Lists available peers and handles the user interface related to connecting to
 a peer.
 */

#import <UIKit/UIKit.h>
#import "PeerSessionManager.h"
#import "Geoloqi.h"

typedef enum {
    InvitationTypeEmail,
    InvitationTypeWireless
} InvitationType;

@interface PeerLobbyController : UIViewController <UITableViewDelegate, UITableViewDataSource, SessionManagerLobbyDelegate, UIAlertViewDelegate> {
	NSArray	*peerList;
    UIAlertView *alertView;
	PeerSessionManager *manager;
    IBOutlet UITableView *peerTableView;
    NSString *invitationToken;
    NSString *receivedInvitationToken;
	LQHTTPRequestCallback invitationCreatedCallback;
    LQHTTPRequestCallback claimInvitationBlock;
    LQHTTPRequestCallback confirmInvitationBlock;

    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet UIView *blocker;
    IBOutlet UIView *blockerContainer;
    IBOutlet UILabel *invitationStatusLabel;
    InvitationType invitationType;
    NSString *invitedPeer;
//    NSDictionary *invitation;
}

@property (nonatomic, readonly) PeerSessionManager *manager; 
@property (nonatomic, assign) IBOutlet UITableView *peerTableView;
@property (nonatomic, retain) NSString *invitedPeer;

- (void) peerListDidChange:(PeerSessionManager *)session;
- (void) didReceiveInvitation:(PeerSessionManager *)session fromPeer:(NSString *)participantID;
- (void) invitationDidFail:(PeerSessionManager *)session fromPeer:(NSString *)participantID;
- (void) setBlockerHidden:(BOOL)hide animated:(BOOL)animated;
- (void) presentServerErrorAlert;

//- (void) sendPacket:(PacketType)packetType;

@end
