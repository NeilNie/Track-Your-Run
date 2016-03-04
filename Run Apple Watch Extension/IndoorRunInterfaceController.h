//
//  IndoorRunInterfaceController.h
//  Run
//
//  Created by Yongyang Nie on 2/20/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import <CoreMotion/CoreMotion.h>
#import "Math.h"
#import "InterfaceController.h"
#import "DetailInterfaceController.h"

BOOL started;

@interface IndoorRunInterfaceController : WKInterfaceController <HKWorkoutSessionDelegate> {
    
    HKHealthStore *healthStore;
    HKWorkoutSession *workoutSession;
    HKAnchoredObjectQuery *heartQuery;
    HKAnchoredObjectQuery *distanceQuery;
    NSPredicate *Predicate;
    
    CMPedometer *Pedometer;
    
    NSTimer *timerIndoor;
    NSTimer *Timer;
    
    BOOL disBo;
    BOOL timeBo;
    BOOL paceBo;
}

@property int seconds;
@property int miliseconds;
@property float distance;
@property NSMutableArray *heartBeatArray;
@property (nonatomic, strong) NSMutableArray *splitsArray;

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *timeLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *unitLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *milisecondsLabel;
- (IBAction)leftClick;
- (IBAction)rightClick;

@end
