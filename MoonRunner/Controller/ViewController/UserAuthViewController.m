//
//  UserAuthViewController.m
//  Done!
//
//  Created by Yongyang Nie on 5/23/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import "UserAuthViewController.h"
#import "MainViewController.h"

@interface UserAuthViewController ()

@end

@implementation UserAuthViewController

- (IBAction)Register:(id)sender {

    [[FIRAuth auth] createUserWithEmail:self.email.text password:self.password.text completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        
        NSLog(@"resigstered user %@", user);
        NSLog(@"error %@", error);
        NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
        NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
        [[[_ref child:@"users"] child:self.username.text] setValue:@{@"email": self.email.text,
                                                                     @"UUID": [self uuid],
                                                                     @"region": countryCode,
                                                                     @"register_date": [[self dateFormatter] stringFromDate:[NSDate date]]}];
        
        FIRUserProfileChangeRequest *changeRequest = [user profileChangeRequest];
        changeRequest.displayName = self.username.text;
        [changeRequest commitChangesWithCompletion:^(NSError *_Nullable error) {
            if (error) {
                NSLog(@"%@", error);
            }
        }];
        
        [self showIntro];
    }];
}

- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd/MM/yyyy HH:MM";
    }
    
    return dateFormatter;
}

- (NSString *)uuid
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge_transfer NSString *)uuidStringRef;
}

- (IBAction)login:(id)sender {
    
    if (self.password.alpha == 0) {
        [UIView animateWithDuration:0.5 animations:^{
            self.registerB.alpha = 0;
            self.registerBbg.alpha = 0;
            
            [UIView animateWithDuration:0.4 animations:^{
                self.constr.constant = 130;
                [self.view layoutIfNeeded];
            }];
            self.loginBbg.image = [UIImage imageNamed:@"button_selected.png"];
            
            self.password.alpha = 1.0;
            self.email.alpha = 1.0;
        }];
    }else{
        [[FIRAuth auth] signInWithEmail:self.email.text password:self.password.text completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
            
            [self showIntro];
        }];
    }
}

-(void)showIntro{
    
//    intro = [[NSUserDefaults standardUserDefaults] boolForKey:@"intro"];
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIWindow *window = [UIApplication sharedApplication].delegate.window;
//    UIViewController *StartView = [storyboard instantiateViewControllerWithIdentifier:@"TipView"];
//    if (intro == NO) {
//        window.rootViewController = StartView;
//        [window makeKeyAndVisible];
//        intro = YES;
//        [[NSUserDefaults standardUserDefaults] setBool:intro forKey:@"intro"];
//    }else{
//        NSLog(@"will display view controller");
//        UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];
//        MainViewController *mainViewController = [storyboard instantiateInitialViewController];
//        mainViewController.rootViewController = navigationController;
//        window.rootViewController = mainViewController;
//        [UIView transitionWithView:window
//                          duration:0.3
//                           options:UIViewAnimationOptionTransitionCrossDissolve
//                        animations:nil
//                        completion:nil];
//        [mainViewController setupWithPresentationStyle:LGSideMenuPresentationStyleSlideBelow type:0];
//    }
    
}
- (IBAction)registerUser:(id)sender {
    
    [UIView animateWithDuration:0.5 animations:^{
        self.registerB.alpha = 0;
        self.registerBbg.alpha = 0;
        
        [UIView animateWithDuration:0.4 animations:^{
            self.constr.constant = 130;
            [self.view layoutIfNeeded];
        }];
        self.loginB.alpha = 0;
        self.registerb2.alpha = 1;
        self.loginBbg.image = [UIImage imageNamed:@"button_selected.png"];
        
        self.username.alpha = 1.0;
        self.password.alpha = 1.0;
        self.email.alpha = 1.0;
    }];
    
}

#pragma mark - MDTextField Delegate

-(BOOL)textFieldShouldReturn:(MDTextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Life Cycle

-(void)viewDidAppear:(BOOL)animated{
    
    self.ref = [[FIRDatabase database] reference];
    NSLog(@"uuid: %@",[self uuid]);
    [super viewDidAppear:YES];
}
- (void)viewDidLoad {
    
    self.email.delegate = self;
    self.username.delegate = self;
    self.password.delegate = self;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
