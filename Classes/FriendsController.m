//
//  FriendsController.m
//  Beacon
//
//  Created by P. Mark Anderson on 11/22/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

#import "FriendsController.h"
#import "BeaconAppDelegate.h"
#import "CJSONDeserializer.h"

@implementation FriendsController

@synthesize friends;

- (void) dealloc 
{
    [friends release];
    [addButtonItem release];
    [invitationToken release];
    
    [super dealloc];
}



- (void) fetchFriends
{
	self.friends = [Friend allFriends];    
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark View lifecycle

- (void) viewDidLoad 
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = self.addButtonItem;
    
    [self fetchFriends];    
}

- (void) viewWillAppear:(BOOL)inAnimated
{
    [super viewWillAppear:inAnimated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:inAnimated];

    [self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)inAnimated
{
    [super viewDidAppear:inAnimated];

    [self.tableView flashScrollIndicators];
    
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


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    Friend *friend;
    
    switch (indexPath.section)
    {
        case 0:
            friend = [friends objectAtIndex:indexPath.row];
            cell.textLabel.text = [friend serverURL];
            cell.detailTextLabel.text = [friend accessToken];
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
- (UIBarButtonItem *) addButtonItem
{
    if (addButtonItem == NULL)
    {
        addButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)] autorelease];
        addButtonItem.enabled = YES;
    }

    return addButtonItem;
}

- (void) composeEmailWithInvitation
{
    EmailController *email = [[EmailController alloc] initWithInvitationCode:invitationToken];
    
    if (email)
    {
        [self presentModalViewController:email animated:YES];
        
        [email release];    
    }    
}

- (GLHTTPRequestCallback)invitationCreatedCallback {
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
            [BeaconAppDelegate alertWithTitle:@"Sorry" message:@"Please try again later."];
        }
        else
        {
            [self composeEmailWithInvitation];
        }
        
		
	} copy];
}

- (IBAction) add:(id)inSender
{
    NSLog(@"Creating invitation...");
    
    [[Geoloqi sharedInstance] createInvitation:[self invitationCreatedCallback]];    
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
    
    [self.tableView reloadData];
    
    //	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];    
    //  [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    //	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
}


@end

