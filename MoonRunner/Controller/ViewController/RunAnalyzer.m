//
//  RunAnalyzer.m
//  Run
//
//  Created by Yongyang Nie on 6/14/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import "RunAnalyzer.h"

@implementation RunAnalyzer

#pragma mark - Constructor

-(instancetype)initWithData:(NSMutableArray *)array run:(Run *)run{
    
    self = [super init];
    if (self) {
        _run = run;
        _runData = array;
        runHelper = [RunHelper new];
    }
    return self;
}

#pragma mark - Analyze Speed

-(NSString *)generalSpeedAnalysis{
    
    NSString *string;
    
    //Comparing with the user
    NSNumber *max = [RunHelper getMaxNumber:[runHelper calculateSpeed:[runHelper retrieveAllObjects]]];
    NSNumber *runSpeed = [NSNumber numberWithFloat:self.run.distance.floatValue / self.run.duration.floatValue];
    if (runSpeed > max) {
        //broke personal record.
        string = [NSString stringWithFormat:@"Congrats, you have broken your speed record %@. The average speed of this run is %@", max, runSpeed];
    }else{
        string = [NSString stringWithFormat:@"Well done, your highest speed overall is %@, and average speed for this run is %@", max, runSpeed];
    }
    return string;

}
-(NSString *)relativeSpeedAnalysis{
    
    NSString *string;

    //Find relative runs
    NSMutableArray *array = [runHelper retrieveObjectsWithDistanceRange:self.run.distance.intValue - 300 andMax:self.run.distance.intValue + 300];
    
    if (array.count >= 1) {
        //get an array of speed from the array calculated above.
        NSMutableArray *speedArray = [runHelper calculateSpeed:array];
        
        //find the average of speed array // then find the speed for this run.
        NSNumber *averageSpeed = [RunHelper getAverageNumber:speedArray];
        NSNumber *currentSpeed = [NSNumber numberWithFloat:self.run.distance.floatValue / self.run.duration.floatValue];
        
        //calculate pave based on speed.
        NSString *currentPace  = [MathController stringifyAvgPaceFromDist:self.run.distance.floatValue overTime:self.run.duration.intValue];
        NSString *averagePace = [MathController stringifyPaceFromSpeed:averageSpeed.floatValue];
        if (currentSpeed > averageSpeed) {
            string = [NSString stringWithFormat:@"Your pace %@ is above the average pace %@ of your workouts at similar distance.", currentPace, averagePace];
        }else{
            string = [NSString stringWithFormat:@"The pace for workouts at similar distance is %@", averagePace];
        }
        return string;
    }else{
        return nil;
    }
}

-(NSString *)relativeEnvironmentAnalysis{
    
    NSString *string;
    
    return string;
}

-(void)beginAnalyzeSpeed{
    
    ///Relative to the environment.
    //speed based on elevation
    
}

#pragma mark - Analyze Heart Rate

-(void)beginAnalyzeHeartRate{
    
}

#pragma mark - Analyze Elevation

-(void)beginAnalyzeElevation{
    
}

#pragma mark - Analyze Strides

-(void)beginAnalyzeHeartStrides{
    
}

@end
