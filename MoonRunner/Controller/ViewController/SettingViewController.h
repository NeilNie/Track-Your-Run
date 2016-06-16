//
//  SettingViewController.h
//  Run
//
//  Created by Yongyang Nie on 3/4/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import <MessageUI/MessageUI.h>

BOOL areAdsRemoved;
BOOL useMetric;
BOOL useAnalysis;

@interface SettingViewController : UIViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver, MFMailComposeViewControllerDelegate>{
    
    IBOutlet UISwitch *ads;
    IBOutlet UISwitch *metric;
    IBOutlet UISwitch *analysis;
}

- (IBAction)restore;
- (IBAction)tapsRemoveAds;

@end
