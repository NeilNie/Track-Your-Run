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

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
}

- (void)willActivate {
    
    re = NO;
    self.locations = [[NSMutableArray alloc] init];
    self.heartBeatArray = [[NSMutableArray alloc] init];
    if (!self.splitsArray) {
        self.splitsArray = [[NSMutableArray alloc] init];
    }
    [self.splitsArray removeAllObjects];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(eachSecond) userInfo:nil repeats:YES];
    
    healthStore = [[HKHealthStore alloc] init];
    workoutSession = [[HKWorkoutSession alloc] initWithActivityType:HKWorkoutActivityTypeRunning locationType:HKWorkoutSessionLocationTypeOutdoor];
    workoutSession.delegate = self;
    [healthStore startWorkoutSession:workoutSession];
    
    [self startLocationUpdates];
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    
    NSLog(@"did deactivate");
    //[healthStore endWorkoutSession:workoutSession];
    //[healthStore stopQuery:heartQuery];
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark - IBActions

- (IBAction)stopPressed:(id)sender{
    
    float hightest = 0.0;
    for (int i = 0; i < self.heartBeatArray.count; i++) {
        if ([[self.heartBeatArray objectAtIndex:i] floatValue] > hightest) {
            hightest = [[self.heartBeatArray objectAtIndex:i] floatValue];
        }
    }
    //float energy = [[self.EnergyArray lastObject] floatValue] / 4.148;
    NSLog(@"%f", hightest);
    data = @{@"time": [NSString stringWithFormat:@"%i", self.seconds], @"distance": [NSString stringWithFormat:@"%f", self.distance], @"splits": self.splitsArray, @"max": [NSString stringWithFormat:@"%f", hightest]};
    NSLog(@"data %@", data);
    
    [timer invalidate];
    [self.locationManager stopUpdatingLocation];
    [healthStore endWorkoutSession:workoutSession];
    [healthStore stopQuery:heartQuery];
    
    [self pushControllerWithName:@"detail" context:nil];
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

#pragma mark - HealthKit Delegate

-(void)updateEnergy:(NSDate *)startDate{
    
    __weak typeof(self) weakSelf = self;
    
    NSPredicate *Predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:nil options:HKQueryOptionNone];
    HKSampleType *object = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    
    energyQuery = [[HKAnchoredObjectQuery alloc] initWithType:object predicate:Predicate anchor:0 limit:0 resultsHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *sampleObjects, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *newAnchor, NSError *error) {
        
        if (!error && sampleObjects.count > 0) {
            
            HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects objectAtIndex:0];
            HKQuantity *quantity = sample.quantity;
            [weakSelf.EnergyArray addObject:[NSString stringWithFormat:@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"J"]]]];
        }else{
            NSLog(@"query %@", error);
        }
        
    }];
    [energyQuery setUpdateHandler:^(HKAnchoredObjectQuery *query, NSArray<HKSample *> *SampleArray, NSArray<HKDeletedObject *> *deletedObjects, HKQueryAnchor *Anchor, NSError *error) {
        
        if (!error && SampleArray.count > 0) {
            HKQuantitySample *sample = (HKQuantitySample *)[SampleArray objectAtIndex:0];
            HKQuantity *quantity = sample.quantity;
            [weakSelf.EnergyArray addObject:[NSString stringWithFormat:@"%f", [quantity doubleValueForUnit:[HKUnit unitFromString:@"J"]]]];
        }else{
            NSLog(@"query %@", error);
        }
    }];
    [healthStore executeQuery:energyQuery];
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

-(void)workoutSession:(HKWorkoutSession *)workoutSession didFailWithError:(NSError *)error{
    
    NSLog(@"session error %@", error);
}

-(void)workoutSession:(HKWorkoutSession *)workoutSession didChangeToState:(HKWorkoutSessionState)toState fromState:(HKWorkoutSessionState)fromState date:(NSDate *)date{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (toState) {
            case HKWorkoutSessionStateRunning:
                [self updateHeartbeat:date];
                //[self updateEnergy:date];
                NSLog(@"started workout");
                break;
                
            default:
                break;
        }
    });
}
#pragma mark - Private

- (void)eachSecond
{
    self.seconds ++;
    [self updateLabels];
    [self.locationManager requestLocation];
}

- (void)updateLabels{
    
    [self.timeLabel setText:[NSString stringWithFormat:@"%@",  [Math stringifySecondCount:self.seconds usingLongFormat:NO]]];
    [self.distLabel setText:[NSString stringWithFormat:@"%@", [Math stringifyDistance:self.distance]]];
    [self.paceLabel setText:[NSString stringWithFormat:@"%@",  [Math stringifyAvgPaceFromDist:self.distance overTime:self.seconds]]];
}

- (void)startLocationUpdates{
    
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Movement threshold for new events.
    self.locationManager.distanceFilter = 10; // meters
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager requestLocation];
    NSLog(@"started update location");
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    for (CLLocation *newLocation in locations) {
        
        NSDate *eventDate = newLocation.timestamp;
        
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20) {
            
            // update distance
            if (self.locations.count > 0) {
                self.distance += [newLocation distanceFromLocation:self.locations.lastObject];
            }
            
            [self.locations addObject:newLocation];
        }
    }
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    NSLog(@"%@", error);
}

@end
