//
//  UserAuthViewController.h
//  Done!
//
//  Created by Yongyang Nie on 5/23/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDTextField.h"

@import FirebaseAuth;
@import FirebaseDatabase;

@interface UserAuthViewController : UIViewController <MDTextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UIButton *registerB;
@property (weak, nonatomic) IBOutlet UIImageView *registerBbg;
@property (weak, nonatomic) IBOutlet UIButton *loginB;
@property (weak, nonatomic) IBOutlet UIImageView *loginBbg;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet MDTextField *username;
@property (weak, nonatomic) IBOutlet MDTextField *password;
@property (weak, nonatomic) IBOutlet MDTextField *email;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constr;
@property (weak, nonatomic) IBOutlet UIButton *registerb2;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@end
