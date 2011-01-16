//
//  NicknameController.m
//  SocialSonar
//
//  Created by P. Mark Anderson on 1/16/11.
//  Copyright 2011 Spot Metrix, Inc. All rights reserved.
//

#import "NicknameController.h"


@implementation NicknameController

@synthesize delegate;

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    [nickname becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
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


- (void)dealloc {
    [super dealloc];
}

#pragma mark -

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"starting");
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return ([textField.text length] > 0);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    form.alpha = 0.0;
    header.alpha = 0.20;
    header.textColor = [UIColor blackColor];

    header.transform = CGAffineTransformConcat(
        CGAffineTransformMakeTranslation(0, 40),
        CGAffineTransformMakeScale(3.0, 3.0)
    );
    
    [UIView commitAnimations];
    
    [textField resignFirstResponder];
    textField.enabled = NO;
    textField.textColor = [UIColor lightGrayColor];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"Nickname is: %@", textField.text);
    [spinner startAnimating];    
    
    [delegate nicknameController:self didReturnName:textField.text];
}


@end
