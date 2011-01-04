//
//  MapController.h
//  Beacon
//
//  Created by P. Mark Anderson on 11/21/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SM3DAR.h"
#import "Geoloqi.h"

@interface MapController : UIViewController <SM3DAR_Delegate> 
{
	LQHTTPRequestCallback friendPositionsCallback;
    IBOutlet UIView *hud;
}

- (IBAction) settingsButtonTapped:(UIButton *)button;
- (IBAction) friendsButtonTapped:(UIButton *)button;

@end
