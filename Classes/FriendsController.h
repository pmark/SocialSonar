//
//  FriendsController.h
//  Beacon
//
//  Created by P. Mark Anderson on 11/22/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"
#import "EmailController.h"
#import "Geoloqi.h"


@interface FriendsController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *friends;
	LQHTTPRequestCallback invitationCreatedCallback;
    NSString *invitationToken;
    IBOutlet UITableView *tableView;
}

@property (nonatomic, retain) NSMutableArray *friends;

- (IBAction) add:(id)sender;
- (IBAction) done:(id)sender;


@end
