//
//  SingleFriendController.m
//  Beacon
//
//  Created by P. Mark Anderson on 11/22/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

#import "SingleFriendController.h"

@implementation SingleFriendController

- (void) dealloc 
{
    [super dealloc];
}



#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    Friend *friend;
    
    NSInteger friendCount = (friends ? [friends count] : 0);

    switch (indexPath.section) 
    {
        case 0:
            if (friendCount == 0)
            {
                cell.textLabel.text = @"Tap the plus button";
            }
            else
            {
                friend = [friends objectAtIndex:indexPath.row];
                cell.textLabel.text = [friend description];
            }
            
            break;
            
        case 1:
            cell.textLabel.text = @"Upgrade Now";
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            break;
        default:
            break;
    }

    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *text = nil;

    NSInteger friendCount = (friends ? [friends count] : 0);
    
    switch (section) {
        case 0:
            text = (friendCount == 0 ? @"Invite a Friend" : @"Your Friends");
            break;
        case 1:
            text = @"Get the Full Version";
            break;
        default:
            break;
    }
    
    return text;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *text = nil;
    
    switch (section) {
        case 0:
            text = @"Tap the plus button in the nav bar to send an invitation for location sharing.";
            break;
        case 1:
            text = @"Upgrade to add multiple friends.";
            break;
        default:
            break;
    }
    
    return text;
}


#pragma mark -
#pragma mark Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // Navigation logic may go here. Create and push another view controller.
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
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

@end

