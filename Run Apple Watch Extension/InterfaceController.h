//
//  InterfaceController.h
//  Run Apple Watch Extension
//
//  Created by Yongyang Nie on 2/18/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <HealthKit/HealthKit.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import "Math.h"
#import "Run.h"
#import "Location.h"
#import "DetailInterfaceController.h"

NSDictionary *data;

@interface InterfaceController : WKInterfaceController <CLLocationManagerDelegate, WCSessionDelegate, HKWorkoutSessionDelegate>{
    
    NSTimer *timer;
    NSTimer *heartTimer;
    HKHealthStore *healthStore;
    HKAnchoredObjectQuery *heartQuery;
    HKAnchoredObjectQuery *energyQuery;
    HKAnchoredObjectQuery *distanceQuery;
    HKWorkoutSession *workoutSession;
}

@property int seconds;
@property float distance;
@property NSMutableArray *heartBeatArray;
@property NSMutableArray *EnergyArray;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSMutableArray *splitsArray;

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *timeLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *distLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *paceLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceButton *stopButton;
@property (nonatomic, weak) IBOutlet WKInterfaceButton *splits;

@end
