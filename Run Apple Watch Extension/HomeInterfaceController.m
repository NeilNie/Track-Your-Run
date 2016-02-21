//
//  HomeInterfaceController.m
//  Run
//
//  Created by Yongyang Nie on 2/18/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import "HomeInterfaceController.h"
#import "InterfaceController.h"
#import <Healthkit/HealthKit.h>

@interface HomeInterfaceController ()

@end

@implementation HomeInterfaceController

- (void)awakeWithContext:(id)context {
    
    HKHealthStore *healthStore = [[HKHealthStore alloc] init];
    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKQuantityType *type2 = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKQuantityType *type3 = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    
    [healthStore requestAuthorizationToShareTypes:nil readTypes:[NSSet setWithObjects:type, type2, type3, nil] completion:^(BOOL success, NSError * _Nullable error) {
        
        if (success) {
            NSLog(@"health data request success");
            
        }else{
            NSLog(@"error %@", error);
        }
    }];
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    
    if (localData) {
        [self pushControllerWithName:@"data" context:nil];
    }
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

-(void)sessionWatchStateDidChange:(nonnull WCSession *)session
{
    if(WCSession.isSupported){
        WCSession* session = WCSession.defaultSession;
        session.delegate = self;
        [session activateSession];
        
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



