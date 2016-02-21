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


-(void)updateDistance:(NSDate *)startDate{
    
    __weak typeof(self) weakSelf = self;
    
    NSPredicate *Predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:nil options:HKQueryOptionNone];
    HKSampleType *object = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    heartQuery = [[HKAnchoredObjectQuery alloc] initWithType:object predicate:Predicate anchor:0 limit:0 resultsHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error) {
        
        if (!error && sampleObjects.count > 0) {
            HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects objectAtIndex:0];
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
    [heartQuery setUpdateHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *SampleArray, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *Anchor, NSError *error) {
        
        if (!error && SampleArray.count > 0) {
            HKQuantitySample *sample = (HKQuantitySample *)[SampleArray objectAtIndex:0];
            HKQuantity *quantity = sample.quantity;
            weakSelf.distance = weakSelf.distance + [quantity doubleValueForUnit:[HKUnit unitFromString:@"m"]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.distLabel setText:[Math stringifyDistance:weakSelf.distance]];
                [weakSelf.paceLabel setText:[Math stringifyAvgPaceFromDist:weakSelf.distance overTime:weakSelf.seconds]];
            });
            
        }else{
            NSLog(@"error %@", error);
        }
    }];
    [healthStore executeQuery:heartQuery];
}

-(void)updateHeartbeat:(NSDate *)startDate{
    
    __weak typeof(self) weakSelf = self;
    
    NSPredicate *Predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:nil options:HKQueryOptionNone];
    HKSampleType *object = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    heartQuery = [[HKAnchoredObjectQuery alloc] initWithType:object predicate:Predicate anchor:0 limit:0 resultsHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error) {
        
        if (!error && sampleObjects.count > 0) {
            HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects objectAtIndex:0];
            HKQuantity *quantity = sample.quantity;
            [weakSelf.heartBeatArray addObject:[NSString stringWithFormat:@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]]];
            NSLog(@"heartbeat %@", self.heartBeatArray);
        }else{
            NSLog(@"query %@", error);
        }
        
    }];
    [heartQuery setUpdateHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *SampleArray, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *Anchor, NSError *error) {
        
        if (!error && SampleArray.count > 0) {
            HKQuantitySample *sample = (HKQuantitySample *)[SampleArray objectAtIndex:0];
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
                [self updateHeartbeat:date];
                [self updateDistance:date];
                NSLog(@"started workout");
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
    NSDictionary *dict = @{@"distance": [Math stringifyDistance:self.distance], @"time": [Math stringifySecondCount:self.seconds usingLongFormat:NO], @"heart": [NSString stringWithFormat:@"%f", hightest]};
    [self.heartBeatArray removeAllObjects];
    [self.splitsArray addObject:dict];
    self.distance = 0;
    self.seconds = 0;
    [self.timeLabel setText:@"00:00"];
    [self.distLabel setText:@"0.00mi"];
    NSLog(@"splits: %@", self.splitsArray);
    
}


-(IBAction)stop{
    
    [timer invalidate];
    [healthStore endWorkoutSession:workoutSession];
    [healthStore stopQuery:heartQuery];
    
    float hightest = 0.0;
    for (int i = 0; i < self.heartBeatArray.count; i++) {
        if ([[self.heartBeatArray objectAtIndex:i] floatValue] > hightest) {
            hightest = [[self.heartBeatArray objectAtIndex:i] floatValue];
        }
    }
    //float energy = [[self.EnergyArray lastObject] floatValue] / 4.148;
    NSLog(@"highest heart beat %f", hightest);
    data = @{@"time": [NSString stringWithFormat:@"%i", self.seconds], @"distance": [NSString stringWithFormat:@"%f", self.distance], @"splits": self.splitsArray, @"max": [NSString stringWithFormat:@"%f", hightest]};
    NSLog(@"data %@", data);

    [self pushControllerWithName:@"detail" context:nil];
    
}
-(void)count{
    self.seconds++;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.timeLabel setText:[Math stringifySecondCount:self.seconds usingLongFormat:NO]];
    });
}

- (void)willActivate {
    
    self.heartBeatArray = [[NSMutableArray alloc] init];
    if (!self.splitsArray) {
        self.splitsArray = [[NSMutableArray alloc] init];
    }
    [self.splitsArray removeAllObjects];
    
    self.distance = 0.00;
    self.seconds = 0;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(count) userInfo:nil repeats:YES];
    
    healthStore = [[HKHealthStore alloc] init];
    workoutSession = [[HKWorkoutSession alloc] initWithActivityType:HKWorkoutActivityTypeRunning locationType:HKWorkoutSessionLocationTypeIndoor];
    workoutSession.delegate = self;
    [healthStore startWorkoutSession:workoutSession];
   
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    
    [healthStore endWorkoutSession:workoutSession];
    [healthStore stopQuery:heartQuery];
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end

