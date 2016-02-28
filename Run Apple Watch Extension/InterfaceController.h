//
//  InterfaceController.h
//  Run Apple Watch Extension
//
//  Created by Yongyang Nie on 2/18/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import <CoreMotion/CoreMotion.h>
#import "Math.h"
#import "IndoorRunInterfaceController.h"
#import "DetailInterfaceController.h"

NSDictionary *data;

@interface InterfaceController : WKInterfaceController <HKWorkoutSessionDelegate> {
    
    HKHealthStore *healthStore;
    HKWorkoutSession *workoutSession;
    HKAnchoredObjectQuery *heartQuery;
    HKAnchoredObjectQuery *distanceQuery;
    NSPredicate *Predicate;
    
    CMPedometer *Pedometer;
    
    NSTimer *RunTimer;
    NSTimer *Timer;
}

@property int seconds;
@property int miliseconds;
@property float distance;
@property NSMutableArray *heartBeatArray;
@property (nonatomic, strong) NSMutableArray *splitsArray;

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *timeLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *distLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *paceLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *milisecondsLabel;

@end
