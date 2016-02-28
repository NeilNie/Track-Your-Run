//
//  InterfaceController.m
//  Run Apple Watch Extension
//
//  Created by Yongyang Nie on 2/18/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()

@end

@implementation InterfaceController

-(void)updateDistance{
    
    HKSampleType *object = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    heartQuery = [[HKAnchoredObjectQuery alloc] initWithType:object predicate:Predicate anchor:0 limit:0 resultsHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error) {
        
        if (!error && sampleObjects.count > 0) {
            HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects lastObject];
            HKQuantity *quantity = sample.quantity;
            self.distance = self.distance + [quantity doubleValueForUnit:[HKUnit unitFromString:@"m"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.distLabel setText:[Math stringifyDistance:self.distance]];
                [self.paceLabel setText:[Math stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
            });
            
        }else{
            NSLog(@"error %@", error);
        }
        
    }];
    [healthStore executeQuery:heartQuery];
}

-(void)updateHeartbeat{
    
    HKSampleType *object = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    heartQuery = [[HKAnchoredObjectQuery alloc] initWithType:object predicate:Predicate anchor:0 limit:0 resultsHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error) {
        
        if (!error && sampleObjects.count > 0) {
            HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects lastObject];
            HKQuantity *quantity = sample.quantity;
            [self.heartBeatArray addObject:[NSString stringWithFormat:@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]]];
        }else{
            NSLog(@"query %@", error);
        }
        
    }];
    
    [healthStore executeQuery:heartQuery];
}

#pragma mark - HealthKit Delegate
-(void)workoutSession:(HKWorkoutSession *)workoutSession didFailWithError:(NSError *)error{
    
    NSLog(@"session error %@", error);
}

-(void)workoutSession:(HKWorkoutSession *)workoutSession didChangeToState:(HKWorkoutSessionState)toState fromState:(HKWorkoutSessionState)fromState date:(NSDate *)date{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (toState) {
            case HKWorkoutSessionStateRunning:
                [self updateHeartbeat];
                [self updateDistance];
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

- (IBAction)splitPressed:(id)sender{
    
    float hightest = 0.0;
    for (int i = 0; i < self.heartBeatArray.count; i++) {
        if ([[self.heartBeatArray objectAtIndex:i] floatValue] > hightest) {
            hightest = [[self.heartBeatArray objectAtIndex:i] floatValue];
        }
    }
    NSDictionary *dict = @{@"distance": [Math stringifyDistance:self.distance], @"time": [Math stringifySecondCount:self.seconds usingLongFormat:NO], @"heart": self.heartBeatArray};
    [self.heartBeatArray removeAllObjects];
    [self.splitsArray addObject:dict];
    self.distance = 0;
    self.seconds = 0;
    [self.timeLabel setText:@"00:00"];
    [self.distLabel setText:@"0.00mi"];
    NSLog(@"splits: %@", self.splitsArray);
    
}


-(IBAction)stop{
    
    [Pedometer stopPedometerUpdates];
    [RunTimer invalidate];
    [Timer invalidate];
    [healthStore endWorkoutSession:workoutSession];
    [healthStore stopQuery:heartQuery];
    
    data = @{@"time": [NSString stringWithFormat:@"%i", self.seconds],
             @"distance": [NSString stringWithFormat:@"%f", self.distance],
             @"splits": self.splitsArray, @"max": self.heartBeatArray,
             @"mili": [NSString stringWithFormat:@"%i", self.miliseconds]};

    NSLog(@"data %@", data);
    
    started = NO;
    
    [self pushControllerWithName:@"detail" context:nil];
}

-(IBAction)discard{
    
    [RunTimer invalidate];
    [Timer invalidate];
    [Pedometer stopPedometerUpdates];
    [healthStore endWorkoutSession:workoutSession];
    [healthStore stopQuery:heartQuery];
    
    [self pushControllerWithName:@"home" context:nil];
}

-(void)startPedometer{
    
    Pedometer = [[CMPedometer alloc] init];
    [Pedometer startPedometerUpdatesFromDate:[NSDate dateWithTimeIntervalSinceNow:0] withHandler:^(CMPedometerData *pedometerData, NSError *error) {
        if (!error) {
            NSLog(@"steps %@", [Math stringifyStrideRateFromSteps:pedometerData.numberOfSteps.intValue overTime:self.seconds]);
        }else{
            NSLog(@"%@", error);
        }
    }];
}

-(void)count{
    
    [self updateHeartbeat];
    [self updateDistance];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.timeLabel setText:[Math stringifySecondCount:self.seconds usingLongFormat:NO]];
    });
}

-(void)timerCount{
    
    self.miliseconds++;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.timeLabel setText:[Math stringifySecondCount:self.seconds usingLongFormat:NO]];
        [self.milisecondsLabel setText:[NSString stringWithFormat:@"%i", self.miliseconds]];
    });
    if (self.miliseconds == 100) {
        self.miliseconds = 0;
        self.seconds++;
        NSLog(@"one second");
    }
}

- (void)willActivate {
    
    if (started == NO) {
        self.heartBeatArray = [[NSMutableArray alloc] init];
        if (!self.splitsArray) {
            self.splitsArray = [[NSMutableArray alloc] init];
        }
        [self.splitsArray removeAllObjects];
        
        self.distance = 0.00;
        self.seconds = 0;
        
        RunTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(count) userInfo:nil repeats:YES];
        Timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timerCount) userInfo:nil repeats:YES];
        
        Predicate = [HKQuery predicateForSamplesWithStartDate:[NSDate dateWithTimeIntervalSinceNow:0] endDate:nil options:HKQueryOptionNone];
        healthStore = [[HKHealthStore alloc] init];
        workoutSession = [[HKWorkoutSession alloc] initWithActivityType:HKWorkoutActivityTypeRunning locationType:HKWorkoutSessionLocationTypeIndoor];
        workoutSession.delegate = self;
        [healthStore startWorkoutSession:workoutSession];
        [self startPedometer];
        
        started = YES;
        re = NO;
        NSLog(@"started workout");
    }
    
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    
    NSLog(@"deactivated");
    [super didDeactivate];
}

@end
