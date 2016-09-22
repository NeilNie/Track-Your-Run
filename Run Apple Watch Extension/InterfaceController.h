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
#import "DetailInterfaceController.h"

BOOL started;

@interface InterfaceController : WKInterfaceController <HKWorkoutSessionDelegate> {
    
    HKHealthStore *healthStore;
    HKWorkoutSession *workoutSession;
    HKAnchoredObjectQuery *heartQuery;
    HKAnchoredObjectQuery *distanceQuery;
    NSPredicate *Predicate;
    
    CMPedometer *Pedometer;
    
    NSTimer *CountDown;
    NSTimer *Timer;
}
@property int seconds;
@property int miliseconds;
@property float distance;
@property (strong, nonatomic) NSDictionary *data;
@property (nonatomic, strong) NSMutableArray *heartBeatArray;
@property (nonatomic, strong) NSMutableArray *splitsArray;

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *paceLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *milageLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *heartLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *image;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *timeLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *milisecondsLabel;

@end
