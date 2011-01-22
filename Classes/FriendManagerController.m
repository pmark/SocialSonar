//
//  FriendManagerController.m
//  SocialSonar
//
//  Created by P. Mark Anderson on 1/21/11.
//  Copyright 2011 Spot Metrix, Inc. All rights reserved.
//

#import "FriendManagerController.h"

@implementation FriendManagerController

@synthesize navigationController;


- (void)dealloc {
    self.navigationController = nil;
    
    [super dealloc];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    [self.view addSubview:navigationController.view];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction) done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}



@end
