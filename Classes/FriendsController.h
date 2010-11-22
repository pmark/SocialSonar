//
//  FriendsController.h
//  Beacon
//
//  Created by P. Mark Anderson on 11/22/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FriendsController : UITableViewController 
{
    UIBarButtonItem *addButtonItem;
}

@property (readonly, nonatomic, retain) UIBarButtonItem *addButtonItem;

- (IBAction) add:(id)inSender;


@end
