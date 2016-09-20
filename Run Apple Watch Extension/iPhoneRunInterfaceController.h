//
//  iPhoneRunInterfaceController.h
//  Run
//
//  Created by Yongyang Nie on 3/2/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import <CoreMotion/CoreMotion.h>
#import <HealthKit/HealthKit.h>
#import "Math.h"
#import "InterfaceController.h"

@interface iPhoneRunInterfaceController : WKInterfaceController <WCSessionDelegate, HKWorkoutSessionDelegate>{
    
    CMPedometer *Pedometer;
    HKHealthStore *healthStore;
    HKWorkoutSession *workoutSession;
    HKAnchoredObjectQuery *heartQuery;
    NSPredicate *Predicate;
    NSTimer *Timer;
    NSTimer *QueryTimer;
    NSTimer *countTimer;
    
    BOOL disBo;
    BOOL timeBo;
    BOOL paceBo;
    int countDown;
}

@property int Seconds;
@property int Miliseconds;
@property float Distance;
@property NSMutableArray *HeartBeatArray;
@property (nonatomic, strong) NSMutableArray *splitsArray;

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *timeLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *unitLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *milisecondsLabel;
- (IBAction)leftClick;
- (IBAction)rightClick;

@end
