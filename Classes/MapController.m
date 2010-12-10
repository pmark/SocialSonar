//
//  MapController.m
//  Beacon
//
//  Created by P. Mark Anderson on 11/21/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

#import "MapController.h"
#import "CJSONDeserializer.h"
#import "Friend.h"

@implementation MapController


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void) viewDidLoad 
{
    [super viewDidLoad];
	
//	SM3DAR.delegate = self;	
//    SM3DAR.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
//    [self.view addSubview:SM3DAR.view];

    [self loadPointsOfInterest];
}

- (void) sm3darViewDidLoad
{
    // TODO: set 3DAR delegate at init time.
}

- (LQHTTPRequestCallback)friendPositionsCallback {
	if (friendPositionsCallback) return friendPositionsCallback;
    
	return friendPositionsCallback = [^(NSError *error, NSString *responseBody) 
    {
        NSLog(@"Friend locations fetched.");
        
        NSLog(@"Response: %@", responseBody);
        return;
        
        NSError *err = nil;
        NSDictionary *res = [[CJSONDeserializer deserializer] 
                             deserializeAsDictionary:[responseBody dataUsingEncoding:NSUTF8StringEncoding]
                                               error:&err];
        
        if (!res || [res objectForKey:@"error"] != nil) 
        {
            NSLog(@"Error deserializing response (for location/last) \"%@\": %@", responseBody, err);
            [[Geoloqi sharedInstance] errorProcessingAPIRequest];
            return;
        }
                
    } copy];
}

- (void) loadPointsOfInterest
{
	// Fetch friend locations.
    
    [[Geoloqi sharedInstance] getLastPositions:[Friend allFriends] 
                                      callback:[self friendPositionsCallback]];
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
