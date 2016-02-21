//
//  HealthKitManager.m
//  Run
//
//  Created by Yongyang Nie on 2/19/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import "HealthKitManager.h"

@interface HealthKitManager ()

@property (nonatomic, retain) HKHealthStore *healthStore;

@end


@implementation HealthKitManager

+ (HealthKitManager *)sharedManager {
    static dispatch_once_t pred = 0;
    static HealthKitManager *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[HealthKitManager alloc] init];
        instance.healthStore = [[HKHealthStore alloc] init];
    });
    return instance;
}

- (void)requestAuthorization {
    
    if ([HKHealthStore isHealthDataAvailable] == NO) {
        // If our device doesn't support HealthKit -> return.
        return;
    }
    
    HKQuantityType* type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKQuantityType *type2 = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKQuantityType *type3 = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    
    [self.healthStore requestAuthorizationToShareTypes:nil readTypes:[NSSet setWithObjects:type, type2, type3, nil] completion:^(BOOL success, NSError * _Nullable error) {
        
        NSLog(@"sent request");
        if (success) {
            NSLog(@"success");
            
        }else{
            NSLog(@"error %@", error);
        }
    }];
    
    [self.healthStore requestAuthorizationToShareTypes:[NSSet setWithObjects:type,type2, nil] readTypes:[NSSet setWithObjects:type,type2, nil] completion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"OK");
        }else{
            NSLog(@"error %@", error);
        }
    }];
}

- (NSDate *)readBirthDate {
    NSError *error;
    NSDate *dateOfBirth = [self.healthStore dateOfBirthWithError:&error];   // Convenience method of HKHealthStore to get date of birth directly.
    
    if (!dateOfBirth) {
        NSLog(@"Either an error occured fetching the user's age information or none has been stored yet. In your app, try to handle this gracefully.");
    }
    
    return dateOfBirth;
}

@end

