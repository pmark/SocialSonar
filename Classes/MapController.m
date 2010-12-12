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
	
	SM3DAR.delegate = self;	
    SM3DAR.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];

    CGRect f = self.view.bounds;
    f.size.height -= 49;  // tab bar height
    SM3DAR.view.frame = f;
    SM3DAR.map.frame = f;
    
    f = SM3DAR.iconLogo.frame;
    f.origin.y = SM3DAR.view.frame.size.height - f.size.height - 10;
    SM3DAR.iconLogo.frame = f;
    
    [self.view addSubview:SM3DAR.view];

    
//    CGRect lf = SM3DAR.iconLogo.frame;
//    lf.origin.y -= 50;
//    SM3DAR.iconLogo.frame = lf;
    
    NSLog(@"3DAR view: %@", SM3DAR.view);

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
        if (error)
        {
            NSLog(@"Error fetching friend locations: %@", [error localizedDescription]);
            return;
        }
        
        NSLog(@"Friend locations fetched: %@", responseBody);        
        return;
        
        NSError *err = nil;
        NSDictionary *res = [[CJSONDeserializer deserializer] 
                             deserializeAsDictionary:[responseBody dataUsingEncoding:NSUTF8StringEncoding]
                                               error:&err];
        
        if (!res || [res objectForKey:@"error"] != nil) 
        {
            NSLog(@"Error deserializing response (for share/last) \"%@\": %@", responseBody, err);
            [[Geoloqi sharedInstance] errorProcessingAPIRequest];
            return;
        }
                
    } copy];
}

- (void) fetchFriends
{
    [[Geoloqi sharedInstance] getLastPositions:[Friend allFriendAccessTokens] 
                                      callback:[self friendPositionsCallback]];
}

- (void) loadPointsOfInterest
{
	// Fetch friend locations.
    
	
}

- (void) logoWasTapped
{
    [self fetchFriends];
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
