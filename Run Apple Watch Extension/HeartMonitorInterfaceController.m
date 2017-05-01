//
//  HeartMonitorInterfaceController.m
//  Run
//
//  Created by Yongyang Nie on 2/23/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import "HeartMonitorInterfaceController.h"

@interface HeartMonitorInterfaceController ()

@end

@implementation HeartMonitorInterfaceController

#pragma mark - Private

-(IBAction)stop{

    [timer invalidate];
    [timeTimer invalidate];
    [healthStore endWorkoutSession:workoutSession];
    [healthStore stopQuery:heartQuery];
    
    NSLog(@"%i", self.heartBeatArray.count);
    int low = [[self.heartBeatArray lastObject] intValue];
    for (int i = 0; i < self.heartBeatArray.count; i++) {
        int val = [[self.heartBeatArray objectAtIndex:i] intValue];
        if (val < low && val != 0) {
            low = val;
        }
    }
    [self.LowestLabel setText:[NSString stringWithFormat:@"%ibpm", low]];
}

-(IBAction)clear{
    
    [self.heartBeatArray removeAllObjects];
    self.Seconds = 0;
    self.Miliseconds = 0;
    
    [self.secondLabel setText:@"00:00"];
    [self.milisecondLabel setText:@"'00"];
    [self.LowestLabel setText:@"0bpm"];
    [self.currentLabel setText:@"0bpm"];
}

-(void)timerCount{
    
    self.Miliseconds+=10;
    [self.milisecondLabel setText:[NSString stringWithFormat:@"'%i", self.Miliseconds]];
    
    if (self.Miliseconds == 100) {
        self.Miliseconds = 0;
        self.Seconds++;
        [self.secondLabel setText:[Math stringifySecondCount:self.Seconds usingLongFormat:NO]];
    }
}


#pragma mark - HealthKit Delegate

-(void)updateHeartbeat{
    
    HKSampleType *object = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    heartQuery = [[HKAnchoredObjectQuery alloc] initWithType:object predicate:Predicate anchor:0 limit:0 resultsHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error) {
        
        HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects lastObject];
        NSNumber *val = [NSNumber numberWithInt:[sample.quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]];
        if (!error && val > 0) {
            [self.heartBeatArray addObject:val];
            [self.currentLabel setText:[NSString stringWithFormat:@"%@bpm", val]];
        }else{
            NSLog(@"query %@", error);
        }
        
    }];
    
    [healthStore executeQuery:heartQuery];
}

-(void)workoutSession:(HKWorkoutSession *)workoutSession didFailWithError:(NSError *)error{
    
    NSLog(@"session error %@", error);
}

-(void)workoutSession:(HKWorkoutSession *)workoutSession didChangeToState:(HKWorkoutSessionState)toState fromState:(HKWorkoutSessionState)fromState date:(NSDate *)date{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (toState) {
            case HKWorkoutSessionStateRunning:
                [self updateHeartbeat];
                NSLog(@"started workout");
                break;
            case HKWorkoutSessionStateEnded:
                NSLog(@"ended");
                break;
            case HKWorkoutSessionStateNotStarted:
                NSLog(@"not started");
                break;
                
            default:
                break;
        }
    });
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    
    if (started == NO) {
        
        self.heartBeatArray = [[NSMutableArray alloc] init];
    
        //setup & start workout session
        Predicate = [HKQuery predicateForSamplesWithStartDate:[NSDate dateWithTimeIntervalSinceNow:0] endDate:nil options:HKQueryOptionNone];
        healthStore = [[HKHealthStore alloc] init];
        HKWorkoutConfiguration *config = [[HKWorkoutConfiguration alloc] init];
        config.activityType = HKWorkoutActivityTypeRunning;
        config.locationType = HKWorkoutSessionLocationTypeIndoor;
        workoutSession =  [[HKWorkoutSession alloc] initWithConfiguration:config error:nil];
        workoutSession.delegate = self;
        [healthStore startWorkoutSession:workoutSession];
        
        //initialize the timers
        timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(updateHeartbeat) userInfo:nil repeats:YES];
        timeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerCount) userInfo:nil repeats:YES];
        
        started = YES;
    }
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end
