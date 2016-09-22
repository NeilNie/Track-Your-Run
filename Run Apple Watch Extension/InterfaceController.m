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

#pragma mark - Query HealthKit

-(void)updateDistance{
    
    __weak typeof(self) weakSelf = self;
    
    HKSampleType *object = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    distanceQuery = [[HKAnchoredObjectQuery alloc] initWithType:object predicate:Predicate anchor:0 limit:0 resultsHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error) {
        
        if (!error && sampleObjects) {
            HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects lastObject];
            self.distance = self.distance + [sample.quantity doubleValueForUnit:[HKUnit unitFromString:@"m"]];
            [self.milageLabel setText:[Math stringifyDistance:weakSelf.distance]];
            [self.paceLabel setText:[Math stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
        }else{
            NSLog(@"error %@", error);
        }
        
    }];
    [distanceQuery setUpdateHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error) {
        
        if (!error && sampleObjects) {
            HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects lastObject];
            weakSelf.distance = self.distance + [sample.quantity doubleValueForUnit:[HKUnit unitFromString:@"m"]];
            [weakSelf.milageLabel setText:[Math stringifyDistance:weakSelf.distance]];
            [weakSelf.paceLabel setText:[Math stringifyAvgPaceFromDist:weakSelf.distance overTime:weakSelf.seconds]];
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
            [self.heartBeatArray addObject:[NSString stringWithFormat:@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]]];
            [self.heartLabel setText:[NSString stringWithFormat:@"%@BPM", [self.heartBeatArray lastObject]]];
        }else{
            NSLog(@"query %@", error);
        }
        
    }];
    [heartQuery setUpdateHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error){
        
        if (!error && sampleObjects.count > 0) {
            HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects lastObject];
            HKQuantity *quantity = sample.quantity;
            [weakSelf.heartBeatArray addObject:[NSString stringWithFormat:@"%.0f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]]];
            [weakSelf.heartLabel setText:[NSString stringWithFormat:@"%@BPM", [weakSelf.heartBeatArray lastObject]]];
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
                [self startPedometer];
                started = YES;
                NSLog(@"workout started");
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

- (IBAction)splitPressed:(id)sender{

    NSDictionary *dict = @{@"distance": [Math stringifyDistance:self.distance],
                           @"time": [Math stringifySecondCount:self.seconds usingLongFormat:NO],
                           @"heart": self.heartBeatArray,
                           @"mili": [NSString stringWithFormat:@"%i", self.miliseconds]};
    [self.heartBeatArray removeAllObjects];
    [self.splitsArray addObject:dict];
    self.distance = 0;
    self.seconds = 0;
    [self.timeLabel setText:@"00:00"];
}

-(IBAction)stop{
    
    [Pedometer stopPedometerUpdates];
    [Timer invalidate];
    [healthStore endWorkoutSession:workoutSession];
    [healthStore stopQuery:heartQuery];
    [healthStore stopQuery:distanceQuery];
    
    self.data = @{@"time": [NSString stringWithFormat:@"%i", self.seconds],
             @"distance": [NSString stringWithFormat:@"%f", self.distance],
             @"splits": self.splitsArray,
             @"heart": self.heartBeatArray,
             @"mili": [NSString stringWithFormat:@"%i", self.miliseconds]};

    NSLog(@"data %@", self.data);
    
    started = NO;
    
    [self pushControllerWithName:@"detail" context:self.data];
}

-(IBAction)discard{
    
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

-(void)timerCount{
    
    self.miliseconds+=10;
    [self.milisecondsLabel setText:[NSString stringWithFormat:@"%i", self.miliseconds]];
    if (self.miliseconds == 100) {
        self.miliseconds = 0;
        self.seconds++;
        [self.timeLabel setText:[Math stringifySecondCount:self.seconds usingLongFormat:NO]];
    }
}

-(void)countDown{
    
    static int count = 1;
    static int start = 1;
    CountDown = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
    [self.image startAnimatingWithImagesInRange:NSMakeRange(start, count * 30) duration:0.3 repeatCount:1];
    [self.image startAnimatingWithImagesInRange:NSMakeRange(count * 30, count * 30 + 4) duration:0.5 repeatCount:1];
        count ++;
        start = start + 34;
        if (count == 4) {
            [CountDown invalidate];
    
            [self.image setHidden:YES];
            [self.timeLabel setHidden:NO];
            [self.paceLabel setHidden:NO];
            [self.milageLabel setHidden:NO];
            [self.heartLabel setHidden:NO];
            
            Timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerCount) userInfo:nil repeats:YES];
            
            Predicate = [HKQuery predicateForSamplesWithStartDate:[NSDate dateWithTimeIntervalSinceNow:0] endDate:nil options:HKQueryOptionNone];
            healthStore = [[HKHealthStore alloc] init];
            workoutSession = [[HKWorkoutSession alloc] initWithActivityType:HKWorkoutActivityTypeRunning locationType:HKWorkoutSessionLocationTypeIndoor];
            workoutSession.delegate = self;
            [healthStore startWorkoutSession:workoutSession];
        }
    }];
}

#pragma mark - Life Cycle

- (void)willActivate {
    
    if (started == NO) {
        
        self.heartBeatArray = [[NSMutableArray alloc] init];
        self.splitsArray = [[NSMutableArray alloc] init];
        self.distance = 0.00;
        self.seconds = 0;
        
        [self.timeLabel setHidden:YES];
        [self.paceLabel setHidden:YES];
        [self.milageLabel setHidden:YES];
        [self.heartLabel setHidden:YES];
        [self.image setImageNamed:@"single"];
        
        CountDown = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    }
    
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    
    [super didDeactivate];
}
- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

@end
