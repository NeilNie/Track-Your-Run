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
#import "Math.h"

@interface HeartMonitorInterfaceController : WKInterfaceController <HKWorkoutSessionDelegate> {
    
    HKHealthStore *healthStore;
    HKWorkoutSession *workoutSession;
    HKAnchoredObjectQuery *heartQuery;
    HKAnchoredObjectQuery *distanceQuery;
    NSPredicate *Predicate;
    
    NSTimer *timer;
    NSTimer *timeTimer;
    BOOL isClear;
}
@property int Seconds;
@property int Miliseconds;
@property NSMutableArray *heartBeatArray;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *currentLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *LowestLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *secondLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *milisecondLabel;

@end
