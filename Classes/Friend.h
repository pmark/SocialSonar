//
//  Friend.h
//  Beacon
//
//  Created by P. Mark Anderson on 11/21/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

@interface Friend : NSManagedObject  
{
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *accessLink;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, retain) NSDate *createdAt;

@end



