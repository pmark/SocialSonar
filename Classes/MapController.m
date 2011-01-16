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
#import "SM3DAR.h"
#import "SphereView.h"
#import "Constants.h"
#import "ShareController.h"
#import "SingleFriendController.h"
#import "FriendsController.h"

@implementation MapController

- (void)dealloc 
{
    RELEASE(hud);
    
    [super dealloc];
}


- (void) viewDidLoad 
{
    [super viewDidLoad];
	
	SM3DAR.delegate = self;	
    SM3DAR.view.backgroundColor = [UIColor clearColor];

/*
    CGRect f = self.view.bounds;
    f.size.height -= 49;  // tab bar height
    SM3DAR.view.frame = f;
    SM3DAR.map.frame = f;
    
    f = SM3DAR.iconLogo.frame;
    f.origin.y = SM3DAR.view.frame.size.height - f.size.height - 10;
    SM3DAR.iconLogo.frame = f;
*/
    CALayer *l = centerMenu.layer;
    [l setMasksToBounds:YES];
    [l setCornerRadius:7.0];
    [l setBorderWidth:2.0];
    [l setBorderColor:[[UIColor darkGrayColor] CGColor]];
    
    SM3DAR.hudView = hud;
    
    SM3DAR.iconLogo.hidden = YES;
    [self.view insertSubview:SM3DAR.view atIndex:0];
    

//    [self loadPointsOfInterest];
}

- (void) sm3darViewDidLoad
{
    // TODO: set 3DAR delegate at init time.
}

- (CLLocation *)parseLocation:(NSDictionary *)data
{
    NSDictionary *position = [[data objectForKey:@"location"] objectForKey:@"position"];

    id latitude = [position objectForKey:@"latitude"];
    id longitude = [position objectForKey:@"longitude"];
    
    NSLog(@"lat: %@", latitude);
    
    if ((latitude == [NSNull null] || [latitude length] == 0) || 
        (longitude == [NSNull null] || [longitude length] == 0))
    {
        NSLog(@"Friend location is missing coordinates.");
        return nil;
    }

     NSString *hacc = [position objectForKey:@"horizontal_accuracy"];
     NSString *vacc = [position objectForKey:@"vertical_accuracy"];

    CLLocationCoordinate2D coord;
    coord.latitude = [latitude doubleValue];
    coord.longitude = [longitude doubleValue];
    
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *tstamp = [dateFormatter dateFromString:[data objectForKey:@"date"]];
    
    return [[[CLLocation alloc] initWithCoordinate:coord 
                                          altitude:0 
                                horizontalAccuracy:[hacc doubleValue]
                                  verticalAccuracy:[vacc doubleValue]
                                         timestamp:tstamp] autorelease];
}

- (void) addFriendLocationsToScene:(NSArray *)locations
{
    [SM3DAR removeAllPointsOfInterest];
    
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:[locations count]];
    
    for (CLLocation *location in locations)
    {        
        SM3DAR_Point *p = [SM3DAR initPointOfInterestWithLatitude:location.coordinate.latitude
                                                        longitude:location.coordinate.longitude 
                                                         altitude:location.altitude
                                                            title:@"Friend"
                                                         subtitle:nil
                                                  markerViewClass:nil //[SphereView class]
                                                       properties:nil];

        [points addObject:p];
        [p release];
    }
        
    
    [SM3DAR.map addAnnotations:points];

    [SM3DAR addPointsOfInterest:points];
    
    [SM3DAR zoomMapToFitPointsIncludingUserLocation:YES];
}

- (LQHTTPRequestCallback) friendPositionsCallback 
{
	if (friendPositionsCallback) return friendPositionsCallback;
    
	return friendPositionsCallback = [^(NSError *error, NSString *responseBody) 
    {
        if (error)
        {
            NSLog(@"Error fetching friend locations: %@", [error localizedDescription]);
            return;
        }

        NSLog(@"Friend locations fetched: %@", responseBody);
        
        NSError *err = nil;
        id res = [[CJSONDeserializer deserializer] 
                             deserialize:[responseBody dataUsingEncoding:NSUTF8StringEncoding] 
                             error:&err];
        
        if (!res) 
        {
            NSLog(@"Error deserializing response (for share/last) \"%@\": %@", responseBody, err);
            [[Geoloqi sharedInstance] errorProcessingAPIRequest];
            return;
        }
        
        NSArray *arr;
        
        if ([res isKindOfClass:[NSDictionary class]])
        {
            if ([res objectForKey:@"error"] != nil)
            {
                NSLog(@"Error in response (for share/last) \"%@\": %@", responseBody, [res objectForKey:@"error"]);
                return;
            }

            arr = [NSArray arrayWithObject:res];
        } 
        else if ([res isKindOfClass:[NSArray class]])
        {
            arr = res;
        }

        // Parse locations.
        
        NSMutableArray *locations = [NSMutableArray arrayWithCapacity:[arr count]];
        
        for (NSDictionary *oneLocation in arr)
        {
            CLLocation *l = [self parseLocation:oneLocation];
            if (l)
                [locations addObject:l];
        }

        [self addFriendLocationsToScene:locations];
        
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
    [self fetchFriends];
	
}

- (void) logoWasTapped
{
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

#pragma mark Button actions

- (IBAction) friendsButtonTapped:(UIButton *)button
{
    SingleFriendController *c = [[SingleFriendController alloc] init];
    [self presentModalViewController:c animated:YES];
    [c release];
}

- (IBAction) settingsButtonTapped:(UIButton *)button
{
    ShareController *c = [[ShareController alloc] init];
    [self presentModalViewController:c animated:YES];
    [c release];
}

#pragma mark -

-(void)didShowMap
{
    hud.hidden = YES;
    sideMenuBG.hidden = YES;
}

-(void)didHideMap
{
    hud.hidden = NO;
    sideMenuBG.hidden = NO;
}



@end
