//
//  FriendManagerController.h
//  SocialSonar
//
//  Created by P. Mark Anderson on 1/21/11.
//  Copyright 2011 Spot Metrix, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FriendManagerController : UIViewController {
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

- (IBAction) done:(id)sender;

@end
