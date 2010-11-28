//
//  FriendsController.h
//  Beacon
//
//  Created by P. Mark Anderson on 11/22/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"


@interface FriendsController : UITableViewController 
{
    UIBarButtonItem *addButtonItem;
    NSMutableArray *friends;
}

@property (readonly, nonatomic, retain) UIBarButtonItem *addButtonItem;
@property (nonatomic, retain) NSMutableArray *friends;

- (IBAction) add:(id)inSender;


@end
