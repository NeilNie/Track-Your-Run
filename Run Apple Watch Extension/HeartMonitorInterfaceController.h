//
//  HeartMonitorInterfaceController.h
//  Run
//
//  Created by Yongyang Nie on 2/23/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import "IndoorRunInterfaceController.h"

@interface HeartMonitorInterfaceController : WKInterfaceController <HKWorkoutSessionDelegate> {
    
    HKHealthStore *healthStore;
    HKWorkoutSession *workoutSession;
    HKAnchoredObjectQuery *heartQuery;
    HKAnchoredObjectQuery *distanceQuery;
    NSPredicate *Predicate;
    
    NSTimer *timer;
}
@property NSMutableArray *heartBeatArray;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *currentLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *LowestLabel;

@end
