//
//  HealthKitManager.h
//  Run
//
//  Created by Yongyang Nie on 2/19/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

@interface HealthKitManager : NSObject

+ (HealthKitManager *)sharedManager;

- (void)requestAuthorization;

- (NSDate *)readBirthDate;

@end
