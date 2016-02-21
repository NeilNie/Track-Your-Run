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
#import "Math.h"
#import "InterfaceController.h"

@interface IndoorRunInterfaceController : WKInterfaceController <HKWorkoutSessionDelegate> {
    
    HKHealthStore *healthStore;
    HKWorkoutSession *workoutSession;
    HKAnchoredObjectQuery *heartQuery;
    HKAnchoredObjectQuery *distanceQuery;
    
    NSTimer *timer;
}

@property int seconds;
@property float distance;
@property NSMutableArray *heartBeatArray;
@property (nonatomic, strong) NSMutableArray *splitsArray;

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *timeLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *distLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *paceLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceButton *stopButton;
@property (nonatomic, weak) IBOutlet WKInterfaceButton *splits;

@end
