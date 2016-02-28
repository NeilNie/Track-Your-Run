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
    CGFloat low = 0.00;
    for (int i = 0; i < self.heartBeatArray.count; i++) {
        CGFloat val = [[self.heartBeatArray objectAtIndex:i] floatValue];
        if (val < low && val != 0) {
            low = val;
        }
    }
    [self.LowestLabel setText:[NSString stringWithFormat:@"%f", low]];
}

-(void)updateHeartbeat{
    
    __weak typeof(self) weakSelf = self;
    
    HKSampleType *object = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    heartQuery = [[HKAnchoredObjectQuery alloc] initWithType:object predicate:Predicate anchor:0 limit:0 resultsHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error) {
        
        if (!error && sampleObjects.count > 0) {
            HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects objectAtIndex:0];
            HKQuantity *quantity = sample.quantity;
            [self.heartBeatArray addObject:[NSString stringWithFormat:@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]]];
            [self.currentLabel setText:[NSString stringWithFormat:@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]]];
            NSLog(@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]);
        }else{
            NSLog(@"query %@", error);
        }
        
    }];
    
    [heartQuery setUpdateHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *SampleArray, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *Anchor, NSError *error) {
        
        if (!error) {
            HKQuantitySample *sample = (HKQuantitySample *)[SampleArray objectAtIndex:0];
            HKQuantity *quantity = sample.quantity;
            [weakSelf.heartBeatArray addObject:[NSString stringWithFormat:@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]]];
            [weakSelf.currentLabel setText:[NSString stringWithFormat:@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]]];
            NSLog(@"update %f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]);
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
-(void)count{
    
    NSLog(@"one second");
    [self updateHeartbeat];
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    
    if (started == NO) {
        self.heartBeatArray = [[NSMutableArray alloc] init];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(count) userInfo:nil repeats:YES];
        Predicate = [HKQuery predicateForSamplesWithStartDate:[NSDate dateWithTimeIntervalSinceNow:0] endDate:nil options:HKQueryOptionNone];
        healthStore = [[HKHealthStore alloc] init];
        workoutSession = [[HKWorkoutSession alloc] initWithActivityType:HKWorkoutActivityTypeRunning locationType:HKWorkoutSessionLocationTypeIndoor];
        workoutSession.delegate = self;
        [healthStore startWorkoutSession:workoutSession];
        
        started = YES;
        re = NO;
        NSLog(@"started workout");
    }
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



