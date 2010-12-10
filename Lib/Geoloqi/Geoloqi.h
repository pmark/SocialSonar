/*
 *  Geoloqi.h
 *  Geoloqi API 
 *
 *  Copyright 2010 Geoloqi.com. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define GL_OAUTH_CLIENT_ID	@"1"
#define GL_OAUTH_SECRET		@"1"
#define GL_API_URL          @"https://api.geoloqi.com/1/"


static NSString *const LQAuthenticationSucceededNotification = @"LQAuthenticationSucceededNotification";

typedef void (^LQHTTPRequestCallback)(NSError *error, NSString *responseBody);


@interface Geoloqi : NSObject {}

+ (Geoloqi *) sharedInstance;

#pragma mark Application

- (void)createGeonote:(NSString *)text latitude:(float)latitude longitude:(float)longitude radius:(float)radius callback:(LQHTTPRequestCallback)callback;

- (void)createLink:(NSString *)description minutes:(NSInteger)minutes callback:(LQHTTPRequestCallback)callback;

- (void)layerAppList:(LQHTTPRequestCallback)callback;

- (void)subscribeToLayer:(NSString *)layerID callback:(LQHTTPRequestCallback)callback;

- (void)getLastPositions:(NSArray *)tokens callback:(LQHTTPRequestCallback)callback;

#pragma mark Location

- (void)startOrStopMonitoringLocationIfNecessary;
- (void)setLocationUpdatesTo:(BOOL)state;
- (void)setDistanceFilterTo:(CLLocationDistance)distance;
- (void)setTrackingFrequencyTo:(NSTimeInterval)frequency;
- (void)setSendingFrequencyTo:(NSTimeInterval)frequency;

// Getters for location manager variables
- (CLLocation *)currentLocation;
- (BOOL)locationUpdatesState;
- (CLLocationDistance)distanceFilterDistance;
- (NSTimeInterval)trackingFrequency;
- (NSTimeInterval)sendingFrequency;
- (NSUInteger)locationQueueCount;

- (void)loadHistory:(NSDictionary *)params callback:(LQHTTPRequestCallback)callback;
// sendLocationData takes an array of formatted dictionaries, can be generated using dictionaryFromLocation:
- (void)sendLocationData:(NSMutableArray *)points callback:(LQHTTPRequestCallback)callback;
- (void)sendQueuedPoints;
- (NSDictionary *)dictionaryFromLocation:(CLLocation *)location;

#pragma mark Authentication

- (void)authenticateWithUsername:(NSString *)username
						password:(NSString *)password;
- (void)createAccountWithUsername:(NSString *)username
                     emailAddress:(NSString *)emailAddress;
- (void)createAnonymousAccount;
- (void)createAnonymousAccount:(NSString*)name;

- (void)initTokenAndGetUsername;

#pragma mark Invitation

- (void)createInvitation:(LQHTTPRequestCallback)callback;

- (void)getInvitationAtHost:(NSString *)host token:(NSString *)invitationToken callback:(LQHTTPRequestCallback)callback;

- (void)claimInvitation:(NSString*)invitationToken host:(NSString*)host callback:(LQHTTPRequestCallback)callback;

- (void)confirmInvitation:(NSString*)invitationToken host:(NSString*)host callback:(LQHTTPRequestCallback)callback;

- (void)getAccessTokenForInvitation:(NSString*)invitationToken callback:(LQHTTPRequestCallback)callback;

#pragma mark -

- (void)setOauthClientID:(NSString*)clientID secret:(NSString*)secret;

- (void)setOauthAccessToken:(NSString *)accessToken;

- (void)errorProcessingAPIRequest;

- (NSString *)refreshToken;

- (NSString *)serverURL;

- (BOOL)hasRefreshToken;

- (NSString *)hardware;

+ (NSString *)base64encode:(NSData *)data;


@end
