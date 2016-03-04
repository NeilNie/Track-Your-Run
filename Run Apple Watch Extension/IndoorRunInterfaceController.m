//
//  IndoorRunInterfaceController.m
//  Run
//
//  Created by Yongyang Nie on 2/20/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import "IndoorRunInterfaceController.h"

@interface IndoorRunInterfaceController ()

@end

@implementation IndoorRunInterfaceController

#pragma mark - Query HealthKit

-(void)updateDistance{
    
    __weak typeof(self) weakSelf = self;

    HKSampleType *object = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    distanceQuery = [[HKAnchoredObjectQuery alloc] initWithType:object predicate:Predicate anchor:0 limit:0 resultsHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error) {
        
        if (!error && sampleObjects.count > 0) {
            HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects objectAtIndex:0];
            HKQuantity *quantity = sample.quantity;
            self.distance = self.distance + [quantity doubleValueForUnit:[HKUnit unitFromString:@"m"]];
            
        }else{
            NSLog(@"error %@", error);
        }
        
    }];
    
    [distanceQuery setUpdateHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error) {
        
        if (!error && sampleObjects) {
            HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects lastObject];
            weakSelf.distance = self.distance + [sample.quantity doubleValueForUnit:[HKUnit unitFromString:@"m"]];
        }else{
            NSLog(@"error %@", error);
        }
    }];
    
    [healthStore executeQuery:distanceQuery];
}

-(void)updateHeartbeat{
    
    __weak typeof(self) weakSelf = self;

    HKSampleType *object = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    heartQuery = [[HKAnchoredObjectQuery alloc] initWithType:object predicate:Predicate anchor:0 limit:0 resultsHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error) {
        
        if (!error && sampleObjects.count > 0) {
            HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects objectAtIndex:0];
            [self.heartBeatArray addObject:[NSString stringWithFormat:@"%f", [sample.quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]]];

        }else{
            NSLog(@"query %@", error);
        }
        
    }];
    
    [heartQuery setUpdateHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error){
        
        if (!error && sampleObjects.count > 0) {
            HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects lastObject];
            HKQuantity *quantity = sample.quantity;
            [weakSelf.heartBeatArray addObject:[NSString stringWithFormat:@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]]];
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

#pragma mark - Private Methods

- (IBAction)splitPressed{
    
    float hightest = 0.0;
    for (int i = 0; i < self.heartBeatArray.count; i++) {
        if ([[self.heartBeatArray objectAtIndex:i] floatValue] > hightest) {
            hightest = [[self.heartBeatArray objectAtIndex:i] floatValue];
        }
    }
    NSDictionary *dict = @{@"distance": [Math stringifyDistance:self.distance],
                           @"time": [Math stringifySecondCount:self.seconds usingLongFormat:NO],
                           @"heart": [NSString stringWithFormat:@"%f", hightest],
                           @"mili": [NSString stringWithFormat:@"%i", self.miliseconds]};
    
    [self.heartBeatArray removeAllObjects];
    [self.splitsArray addObject:dict];
    self.miliseconds = 0;
    self.distance = 0;
    self.seconds = 0;
    [self.timeLabel setText:@"00:00"];
    
}

-(IBAction)stop{
    
    [timerIndoor invalidate];
    [healthStore endWorkoutSession:workoutSession];
    [healthStore stopQuery:heartQuery];
    [Pedometer stopPedometerUpdates];
    [healthStore stopQuery:distanceQuery];
    
    //float energy = [[self.EnergyArray lastObject] floatValue] / 4.148;
    data = @{@"time": [NSString stringWithFormat:@"%i", self.seconds],
             @"distance": [NSString stringWithFormat:@"%f", self.distance],
             @"splits": self.splitsArray,
             @"max": self.heartBeatArray,
             @"mili": [NSString stringWithFormat:@"%i", self.miliseconds]};
    
    NSLog(@"data %@", data);
    
    started = NO;

    [self pushControllerWithName:@"detail" context:nil];
}

-(IBAction)discard{
    
    [timerIndoor invalidate];
    [Timer invalidate];
    [Pedometer stopPedometerUpdates];
    [healthStore endWorkoutSession:workoutSession];
    [healthStore stopQuery:heartQuery];
    [healthStore stopQuery:distanceQuery];
    
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
        if (disBo) {
            [self.timeLabel setText:[Math stringifyDistance:self.distance]];
        }
        if (paceBo) {
            [self.timeLabel setText:[Math stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
        }
    });
}

-(void)timerCount{
    
    self.miliseconds++;
    [self.milisecondsLabel setText:[NSString stringWithFormat:@"%i", self.miliseconds]];
    if (self.miliseconds == 10) {
        self.miliseconds = 0;
        self.seconds++;
        if (timeBo) {
            [self.timeLabel setText:[Math stringifySecondCount:self.seconds usingLongFormat:NO]];
        }
    }
}

- (IBAction)leftClick {
    
    //set distance
    if (disBo == NO && paceBo == NO && timeBo == YES) {
        timeBo = NO;
        disBo = YES;
        [self.timeLabel setText:[Math stringifyDistance:self.distance]];
        [self.unitLabel setText:@"miles"];
        NSLog(@"changed to distance");
        return;
    }
    if (disBo == YES && timeBo == NO && paceBo == NO) {
        paceBo = YES;
        disBo = NO;
        [self.timeLabel setText:[Math stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
        [self.unitLabel setText:@"m/mi"];
        NSLog(@"changed to pace");
        return;
    }
    if (paceBo == YES && disBo == NO && timeBo == NO) {
        paceBo = NO;
        timeBo = YES;
        [self.timeLabel setText:[Math stringifySecondCount:self.seconds usingLongFormat:NO]];
        [self.unitLabel setText:@"sec"];
        return;
    }
}
- (IBAction)rightClick {
    
    //set distance
    if (disBo == NO && paceBo == NO && timeBo == YES) {
        timeBo = NO;
        disBo = YES;
        [self.timeLabel setText:[Math stringifyDistance:self.distance]];
        [self.unitLabel setText:@"miles"];
        return;
    }
    //set pace
    if (disBo == YES && timeBo == NO && paceBo == NO) {
        paceBo = YES;
        disBo = NO;
        [self.timeLabel setText:[Math stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
        [self.unitLabel setText:@"m/mi"];
        return;
    }
    //set time
    if (paceBo == YES && disBo == NO && timeBo == NO) {
        paceBo = NO;
        timeBo = YES;
        [self.timeLabel setText:[Math stringifySecondCount:self.seconds usingLongFormat:NO]];
        [self.unitLabel setText:@"sec"];
        return;
    }
}

#pragma mark - Life cycle

- (void)willActivate {
    
    if (started == NO) {
        self.heartBeatArray = [[NSMutableArray alloc] init];
        if (!self.splitsArray) {
            self.splitsArray = [[NSMutableArray alloc] init];
        }
        [self.splitsArray removeAllObjects];
        
        self.distance = 0.00;
        self.seconds = 0;
        
        timerIndoor = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(count) userInfo:nil repeats:YES];
        Timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerCount) userInfo:nil repeats:YES];
        
        Predicate = [HKQuery predicateForSamplesWithStartDate:[NSDate dateWithTimeIntervalSinceNow:0] endDate:nil options:HKQueryOptionNone];
        healthStore = [[HKHealthStore alloc] init];
        workoutSession = [[HKWorkoutSession alloc] initWithActivityType:HKWorkoutActivityTypeRunning locationType:HKWorkoutSessionLocationTypeIndoor];
        workoutSession.delegate = self;
        [healthStore startWorkoutSession:workoutSession];
        
        [self startPedometer];
        re = NO;
        disBo = NO;
        paceBo = NO;
        timeBo = YES;
        started = YES;
        NSLog(@"started workout");
    }
   
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)didDeactivate {

    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end

