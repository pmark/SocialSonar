//
//  FriendsController.m
//  Beacon
//
//  Created by P. Mark Anderson on 11/22/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

#import "FriendsController.h"
#import "SoSoAppDelegate.h"
#import "CJSONDeserializer.h"
#import "PeerLobbyController.h"

@implementation FriendsController

@synthesize friends;

- (void) dealloc 
{
    [friends release];
    [invitationToken release];
    [tableView release];
    
    [super dealloc];
}



- (void) fetchFriends
{
	self.friends = [Friend allFriends];    
    
    [tableView reloadData];
}

#pragma mark -
#pragma mark View lifecycle

- (void) viewDidLoad 
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)inAnimated
{
    [super viewWillAppear:inAnimated];
    
    [self fetchFriends];    
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:inAnimated];

//    [tableView reloadData];
}

- (void) viewDidAppear:(BOOL)inAnimated
{
    [super viewDidAppear:inAnimated];

    [tableView flashScrollIndicators];
    
    [Friend getOpenAccessTokens];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView 
{
    // Return the number of sections.
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{

    NSInteger friendCount = (friends ? [friends count] : 0);
    
    NSInteger rowCount = 1;
                             
    switch (section) 
    {
        case 0:
            rowCount = (friendCount == 0 ? 1 : friendCount);
            break;
        default:
            rowCount = 1;
            break;
    }
    
    return rowCount;
   
}


- (UITableViewCell *) tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    Friend *friend;
    
    switch (indexPath.section)
    {
        case 0:
            if (friends && [friends count] > 0)
            {
                friend = [friends objectAtIndex:indexPath.row];
                cell.textLabel.text = [friend serverURL];
                cell.detailTextLabel.text = [friend accessToken];
            }
            
            break;
        default:
            cell.textLabel.text = @"???";
            break;
    }
    
    return cell;
}

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
}


#pragma mark -
#pragma mark Memory management

- (void) didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void) viewDidUnload 
{
	self.friends = nil;
}


#pragma mark -
- (void) composeEmailWithInvitation
{
    EmailController *email = [[EmailController alloc] initWithInvitationCode:invitationToken];
    
    if (email)
    {
        [self presentModalViewController:email animated:YES];
        
        [email release];    
    }    
}

- (LQHTTPRequestCallback)invitationCreatedCallback {
	if (invitationCreatedCallback) return invitationCreatedCallback;

	return invitationCreatedCallback = [^(NSError *error, NSString *responseBody) 
    {
		NSLog(@"Invitation created.");
		
		NSError *err = nil;
		NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:
																					   NSUTF8StringEncoding]
																				error:&err];
		if (!res || [res objectForKey:@"error"] != nil) 
        {
			NSLog(@"Error deserializing response (for invitation/create) \"%@\": %@", responseBody, err);
			[[Geoloqi sharedInstance] errorProcessingAPIRequest];
			return;
		}
        
        // Successful invitation creation.
        
        invitationToken = [[res objectForKey:@"invitation_token"] retain];        
        
        if ([invitationToken length] == 0)
        {
            [SoSoAppDelegate alertWithTitle:@"Sorry" message:@"Please try again later."];
        }
        else
        {
            // Successful invitation generation.

            [self composeEmailWithInvitation];
            
        }
        
		
	} copy];
}

- (IBAction) add:(id)sender
{
    
    PeerLobbyController *lobby = [[PeerLobbyController alloc] init];
    [self.navigationController pushViewController:lobby animated:YES];
    [lobby release];
    
//    NSLog(@"Creating invitation...");
    
//    [[Geoloqi sharedInstance] createInvitation:[self invitationCreatedCallback]];    
}

- (void) createFriend
{    
	Friend *friend = (Friend *)[NSEntityDescription insertNewObjectForEntityForName:@"Friend" 
                                                             inManagedObjectContext:MOCONTEXT];
	
	[friend setName:@"Sam"];
	
	[friend setCreatedAt:[NSDate date]];
	
	// Commit the change.
	NSError *error;
    
	if (![MOCONTEXT save:&error]) 
    {
		NSLog(@"ERROR adding friend: %@", [error localizedDescription]);        
	}
	
    [friends insertObject:friend atIndex:0];
    
    [tableView reloadData];
    
    //	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];    
    //  [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    //	[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
}


@end

