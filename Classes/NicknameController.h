//
//  NicknameController.h
//  SocialSonar
//
//  Created by P. Mark Anderson on 1/16/11.
//  Copyright 2011 Spot Metrix, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NicknameDelegate;

@interface NicknameController : UIViewController <UITextFieldDelegate> {
    IBOutlet UITextField *nickname;
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet UIView *form;
    IBOutlet UILabel *header;
    id<NicknameDelegate> delegate;
}

@property (nonatomic, assign) id<NicknameDelegate> delegate;

@end


@protocol NicknameDelegate
- (void)nicknameController:(NicknameController*)controller didReturnName:(NSString*)name;
@end