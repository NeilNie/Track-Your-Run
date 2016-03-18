//
//  iPhoneRunInterfaceController.m
//  Run
//
//  Created by Yongyang Nie on 3/2/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import "iPhoneRunInterfaceController.h"

@interface iPhoneRunInterfaceController ()

@end

@implementation iPhoneRunInterfaceController

#pragma mark - Query HealthKit

-(void)updateDistance{
    
    __weak typeof(self) weakSelf = self;
    
    HKSampleType *object = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    distanceQuery = [[HKAnchoredObjectQuery alloc] initWithType:object predicate:Predicate anchor:0 limit:0 resultsHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error) {
        
        if (!error && sampleObjects) {
            HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects lastObject];
            self.Distance = [sample.quantity doubleValueForUnit:[HKUnit unitFromString:@"m"]];
        }else{
            NSLog(@"error %@", error);
        }
        
    }];
    [distanceQuery setUpdateHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error) {
        
        if (!error && sampleObjects) {
            HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects lastObject];
            weakSelf.Distance = [sample.quantity doubleValueForUnit:[HKUnit unitFromString:@"m"]];
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
            HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects lastObject];
            HKQuantity *quantity = sample.quantity;
            [self.HeartBeatArray addObject:[NSString stringWithFormat:@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]]];
        }else{
            NSLog(@"query %@", error);
        }
        
    }];
    [heartQuery setUpdateHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error){
        
        HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects lastObject];
        NSNumber *val = [NSNumber numberWithFloat:[sample.quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]];
        if (!error && val != nil) {
            [weakSelf.HeartBeatArray addObject:val];
            [weakSelf sendHeartData:val];
        }else{
            NSLog(@"query %@", error);
        }
    }];
    
    [healthStore executeQuery:heartQuery];
}

#pragma WatchKit Connectivity

-(void)sendHeartData:(NSNumber *)heartRate{
    
    if ([WCSession isSupported]) {
        NSLog(@"Activated");
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        
        //save data to iphone
        [[WCSession defaultSession] transferUserInfo:@{@"key": @"heart", @"heart": heartRate}];
        NSLog(@"sent message %@", heartRate);
        
    }else{
        NSLog(@"not supported");
    }

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

#pragma mark - Private

- (IBAction)splitPressed:(id)sender{
    
    float hightest = 0.0;
    for (int i = 0; i < self.HeartBeatArray.count; i++) {
        if ([[self.HeartBeatArray objectAtIndex:i] floatValue] > hightest) {
            hightest = [[self.HeartBeatArray objectAtIndex:i] floatValue];
        }
    }
    NSDictionary *dict = @{@"Distance": [Math stringifyDistance:self.Distance],
                           @"time": [Math stringifySecondCount:self.Seconds usingLongFormat:NO],
                           @"heart": self.HeartBeatArray,
                           @"mili": [NSString stringWithFormat:@"%i", self.Miliseconds]};
    [self.HeartBeatArray removeAllObjects];
    [self.splitsArray addObject:dict];
    self.Distance = 0;
    self.Seconds = 0;
    [self.timeLabel setText:@"00:00"];
    
}

-(IBAction)stop{
    
    //stop everything
    [Pedometer stopPedometerUpdates];
    [QueryTimer invalidate];
    [Timer invalidate];
    [healthStore endWorkoutSession:workoutSession];
    [healthStore stopQuery:heartQuery];
    [healthStore stopQuery:distanceQuery];
    
    //save data for interface
    started = NO;
    data = @{@"time": [NSString stringWithFormat:@"%i", self.Seconds],
             @"distance": [NSString stringWithFormat:@"%f", self.Distance],
             @"splits": self.splitsArray,
             @"max": self.HeartBeatArray,
             @"mili": [NSString stringWithFormat:@"%i", self.Miliseconds]};
    NSLog(@"%@", data);
    
    //start WCSession
    if ([WCSession isSupported]) {
        NSLog(@"Activated");
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        
        //save data to iphone
        [[WCSession defaultSession] updateApplicationContext:@{@"key":@"stop"} error:nil];
        NSLog(@"sent");
    }
    
    //push interfaceController
    [self pushControllerWithName:@"home" context:nil];
}

-(IBAction)discard{
    
    [QueryTimer invalidate];
    [Timer invalidate];
    [Pedometer stopPedometerUpdates];
    [healthStore endWorkoutSession:workoutSession];
    [healthStore stopQuery:heartQuery];
    [healthStore stopQuery:distanceQuery];
    
    if ([WCSession isSupported]) {
        NSLog(@"Activated");
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        
        //save data to iphone
        [[WCSession defaultSession] updateApplicationContext:@{@"key":@"discard"} error:nil];
        NSLog(@"sent");
    }
    
    [self pushControllerWithName:@"home" context:nil];
}

-(void)count{
    
    [self updateHeartbeat];
    [self updateDistance];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (disBo) {
            [self.timeLabel setText:[Math stringifyDistance:self.Distance]];
        }
        if (paceBo) {
            [self.timeLabel setText:[Math stringifyAvgPaceFromDist:self.Distance overTime:self.Seconds]];
        }
    });
}

-(void)countDown{
    
    countDown = countDown - 1;
    [self.timeLabel setText:[NSString stringWithFormat:@"%i", countDown]];
    if (countDown == 0) {
        
        [countTimer invalidate];
        
        [self.timeLabel setText:@"00:00"];
        [self.milisecondsLabel setHidden:NO];
        [self.unitLabel setHidden:NO];
        
        self.HeartBeatArray = [NSMutableArray array];
        self.splitsArray = [NSMutableArray array];
        
        QueryTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(count) userInfo:nil repeats:YES];
        Timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerCount) userInfo:nil repeats:YES];
        
        Predicate = [HKQuery predicateForSamplesWithStartDate:[NSDate dateWithTimeIntervalSinceNow:0] endDate:nil options:HKQueryOptionNone];
        healthStore = [[HKHealthStore alloc] init];
        workoutSession = [[HKWorkoutSession alloc] initWithActivityType:HKWorkoutActivityTypeRunning locationType:HKWorkoutSessionLocationTypeIndoor];
        workoutSession.delegate = self;
        [healthStore startWorkoutSession:workoutSession];
        
        self.Distance = 0.00;
        self.Seconds = 0;
        self.Miliseconds = 0;
        //[self startPedometer];
    }
}

-(void)timerCount{
    
    self.Miliseconds+=10;
    [self.milisecondsLabel setText:[NSString stringWithFormat:@"%i", self.Miliseconds]];
    
    if (self.Miliseconds == 100) {
        self.Miliseconds = 0;
        self.Seconds++;
        if (timeBo) {
            [self.timeLabel setText:[Math stringifySecondCount:self.Seconds usingLongFormat:NO]];
        }
    }
}

- (IBAction)leftClick {
    
    //set Distance
    if (disBo == NO && paceBo == NO && timeBo == YES) {
        timeBo = NO;
        disBo = YES;
        [self.timeLabel setText:[Math stringifyDistance:self.Distance]];
        [self.unitLabel setText:@"miles"];
        [self.milisecondsLabel setHidden:YES];
        NSLog(@"changed to Distance");
        return;
    }
    if (disBo == YES && timeBo == NO && paceBo == NO) {
        paceBo = YES;
        disBo = NO;
        [self.timeLabel setText:[Math stringifyAvgPaceFromDist:self.Distance overTime:self.Seconds]];
        [self.unitLabel setText:@"m/mi"];
        [self.milisecondsLabel setHidden:YES];
        NSLog(@"changed to pace");
        return;
    }
    if (paceBo == YES && disBo == NO && timeBo == NO) {
        paceBo = NO;
        timeBo = YES;
        [self.timeLabel setText:[Math stringifySecondCount:self.Seconds usingLongFormat:NO]];
        [self.unitLabel setText:@"sec"];
        [self.milisecondsLabel setHidden:NO];
        return;
    }
}
- (IBAction)rightClick {
    
    //set Distance
    if (disBo == NO && paceBo == NO && timeBo == YES) {
        timeBo = NO;
        disBo = YES;
        [self.timeLabel setText:[Math stringifyDistance:self.Distance]];
        [self.milisecondsLabel setHidden:YES];
        [self.unitLabel setText:@"miles"];
        return;
    }
    //set pace
    if (disBo == YES && timeBo == NO && paceBo == NO) {
        paceBo = YES;
        disBo = NO;
        [self.timeLabel setText:[Math stringifyAvgPaceFromDist:self.Distance overTime:self.Seconds]];
        [self.unitLabel setText:@"m/mi"];
        [self.milisecondsLabel setHidden:YES];
        return;
    }
    //set time
    if (paceBo == YES && disBo == NO && timeBo == NO) {
        paceBo = NO;
        timeBo = YES;
        [self.timeLabel setText:[Math stringifySecondCount:self.Seconds usingLongFormat:NO]];
        [self.unitLabel setText:@"sec"];
        [self.milisecondsLabel setHidden:NO];
        return;
    }
}

#pragma mark - Life Cycle

- (void)awakeWithContext:(id)context {
    
    [super awakeWithContext:context];
    // Configure interface objects here.
}

- (void)willActivate {

    if (!started) {
        [self.milisecondsLabel setHidden:YES];
        [self.unitLabel setHidden:YES];
        
        countDown = 4;
        countTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
        
        disBo = NO;
        paceBo = NO;
        timeBo = YES;
        started = YES;
        re = NO;
    }
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



