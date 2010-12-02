/*
 *  Geoloqi.h
 *  Geoloqi API 
 *
 *  Copyright 2010 Geoloqi.com. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

#define GL_OAUTH_CLIENT_ID	@"1"
#define GL_OAUTH_SECRET		@"1"
#define GL_API_URL          @"https://api.geoloqi.com/1/"


static NSString *const GLAuthenticationSucceededNotification = @"GLAuthenticationSucceededNotification";

typedef void (^GLHTTPRequestCallback)(NSError *error, NSString *responseBody);


@interface Geoloqi : NSObject 
{
}

+ (Geoloqi *) sharedInstance;

- (void)setOauthClientID:(NSString*)clientID secret:(NSString*)secret;

- (void)createGeonote:(NSString *)text latitude:(float)latitude longitude:(float)longitude radius:(float)radius callback:(GLHTTPRequestCallback)callback;

- (void)layerAppList:(GLHTTPRequestCallback)callback;

- (NSDictionary*)getInvitation:(NSString*)invitationToken;

- (void)createLink:(NSString *)description minutes:(NSInteger)minutes callback:(GLHTTPRequestCallback)callback;

- (void)subscribeToLayer:(NSString *)layerID callback:(GLHTTPRequestCallback)callback;

- (void)authenticateWithUsername:(NSString *)username
						password:(NSString *)password;

- (void)createAccountWithUsername:(NSString *)username
                     emailAddress:(NSString *)emailAddress;

- (void)createAnonymousAccount:(NSString *)name;

- (void)initTokenAndGetUsername;

- (void)errorProcessingAPIRequest;

- (NSString *)refreshToken;

- (BOOL)hasRefreshToken;

- (void)createInvitation:(GLHTTPRequestCallback)callback;

- (void)getInvitationAtHost:(NSString *)host token:(NSString *)invitationToken callback:(GLHTTPRequestCallback)callback;

- (void)claimInvitation:(NSString*)invitationToken host:(NSString*)host callback:(GLHTTPRequestCallback)callback;

- (void)confirmInvitation:(NSString*)invitationToken host:(NSString*)host callback:(GLHTTPRequestCallback)callback;

- (void)getAccessTokenForInvitation:(NSString*)invitationToken callback:(GLHTTPRequestCallback)callback;

@end



