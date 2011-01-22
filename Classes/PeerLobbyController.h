/*
 Abstract: Lists available peers and handles the user interface related to connecting to
 a peer.
 */

#import <UIKit/UIKit.h>
#import "PeerSessionManager.h"

@interface PeerLobbyController : UIViewController <UITableViewDelegate, UITableViewDataSource, SessionManagerLobbyDelegate, UIAlertViewDelegate> {
	NSArray	*peerList;
    UIAlertView *alertView;
	PeerSessionManager *manager;
    IBOutlet UITableView *peerTableView;
}

@property (nonatomic, readonly) PeerSessionManager *manager; 
@property (nonatomic, assign) IBOutlet UITableView *peerTableView;

- (void) peerListDidChange:(PeerSessionManager *)session;
- (void) didReceiveInvitation:(PeerSessionManager *)session fromPeer:(NSString *)participantID;
- (void) invitationDidFail:(PeerSessionManager *)session fromPeer:(NSString *)participantID;

@end
