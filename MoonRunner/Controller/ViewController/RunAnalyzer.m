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

-(instancetype)initWithRun:(Run *)run{
    
    self = [super init];
    if (self) {
        _run = run;
        runHelper = [RunHelper new];
        [self setUpData];
    }
    return self;
}

#pragma Public

-(NSString * _Nonnull)returnAnalysisResult{
    
    return returnString;
}

-(void)setUpData{
    
    heartRate = [NSKeyedUnarchiver unarchiveObjectWithData:self.run.heart_rate];
    elevation = [NSKeyedUnarchiver unarchiveObjectWithData:self.run.elevation];
}

#pragma mark - Analyze Speed

-(NSString *)generalSpeedAnalysis{
    
    NSString *string;
    
    //Comparing with the user
    NSNumber *max = [RunHelper getMaxNumber:[RunHelper calculateSpeed:[runHelper retrieveAllObjects]]];
    NSNumber *runSpeed = [NSNumber numberWithFloat:(self.run.distance.floatValue / 1609.344) / (self.run.duration.floatValue / 60.0 / 60.0)];
    if (runSpeed.floatValue > max.floatValue) {
        //broke personal record.
        string = [NSString stringWithFormat:@"Congrats, you have broken your speed record %0.2f (%@). The average speed of this run is %0.2f (%@). ", max.floatValue, [MathController stringifyPaceFromSpeed:max.floatValue], runSpeed.floatValue, [MathController stringifyPaceFromSpeed:runSpeed.floatValue]];
    }else{
        string = [NSString stringWithFormat:@"Well done, your highest speed overall is %0.2f (%@). The average speed of this run is %0.2f (%@). ", max.floatValue, [MathController stringifyPaceFromSpeed:max.floatValue], runSpeed.floatValue, [MathController stringifyPaceFromSpeed:runSpeed.floatValue]];
    }
    return string;

}
-(NSString *)relativeSpeedAnalysis{
    
    NSString *string;

    //Find relative runs
    NSMutableArray *array = [runHelper retrieveObjectsWithDistanceRange:self.run.distance.intValue - 200 andMax:self.run.distance.intValue + 200];
    
    if (array.count >= 1) {
        
        //get an array of speed from the array retrieved above.
        NSMutableArray *speedArray = [RunHelper calculateSpeed:array];
        
        //find the average of speed array // then find the speed for this run.
        NSNumber *averageSpeed = [RunHelper getAverageNumber:speedArray];
        
        //calculate pave based on speed.
        NSString *currentPace  = [MathController stringifyAvgPaceFromDist:self.run.distance.floatValue overTime:self.run.duration.floatValue];
        NSString *averagePace = [MathController stringifyPaceFromSpeed:averageSpeed.floatValue];
        
        if (currentSpeed.floatValue > averageSpeed.floatValue) {
            string = [NSString stringWithFormat:@"Your speed %0.2f (%@) is above the average speed %0.2f (%@) of your workouts at similar distance. The data shows that you are improving.", currentSpeed.floatValue, currentPace, averageSpeed.floatValue, averagePace];
        }else{
            string = [NSString stringWithFormat:@"The speed for workouts at similar distance is %0.2f (%@). ", averageSpeed.floatValue, averagePace];
        }
        return string;
    }else{
        return nil;
    }
}

-(NSString *)environmentSpeedAnalysis{
    
    NSString *string;
    
    NSDictionary *weather = [NSKeyedUnarchiver unarchiveObjectWithData:self.run.weather];
    int temp = [[weather objectForKey:@"temperature"] intValue];
    
    NSMutableArray *speedArray = [RunHelper calculateSpeed:[runHelper retrieveAllObjects]];
    NSNumber *average = [RunHelper getAverageNumber:speedArray];
    
    if (temp > 85 && currentSpeed.floatValue > average.floatValue) {
        string = [NSString stringWithFormat:@"The temperature is hot, however your pace is still above average"];
        return string;
    }else{
        return nil;
    }
}

-(void)beginAnalyzeSpeed{
    
    currentSpeed = [NSNumber numberWithFloat:(self.run.distance.floatValue / 1609.344) / (self.run.duration.floatValue / 60.0 / 60.0)];
    
    returnString = [self generalSpeedAnalysis];
    if ([self relativeSpeedAnalysis]) {
        returnString = [returnString stringByAppendingString:[self relativeSpeedAnalysis]];
    }
    if ([self environmentSpeedAnalysis]) {
        returnString = [returnString stringByAppendingString:[self environmentSpeedAnalysis]];
    }
}

#pragma mark - Analyze Heart Rate

-(NSString *)generalHeartRateAnalysis{
    
    NSString *string;
    
    NSMutableArray *averageHeartRates = [runHelper calculateRowMeanMatrix:heartRate];
    NSNumber *masterAverage = [RunHelper getAverageNumber:averageHeartRates];
    NSNumber *currentAverage = [RunHelper getAverageNumber:heartRate];
    if (currentAverage > masterAverage) {
        string = [NSString stringWithFormat:@"You heart rate is more than the average heart rate of all runs %@bpm", masterAverage];
    }else{
        string = [NSString stringWithFormat:@"You heart rate is less than the average heart rate of all runs %@bpm", masterAverage];
    }
    return string;
}

-(NSString *)relativeHeartRateAnalysis{
    
    NSString *string;
    
    NSMutableArray *distanceArray = [runHelper retrieveObjectsWithDistanceRange:self.run.distance.intValue - 300 andMax:self.run.distance.intValue + 300];
    
    if (distanceArray.count >= 1) {
        NSMutableArray *averageHeartRates = [runHelper calculateRowMeanMatrix:distanceArray];
        NSNumber *masterAverage = [RunHelper getAverageNumber:averageHeartRates];
        NSNumber *currentAverage = [RunHelper getAverageNumber:heartRate];
        
        NSMutableArray *speedArray = [RunHelper calculateSpeed:distanceArray];
        NSNumber *speedAverage = [RunHelper getAverageNumber:speedArray];
        
        if (abs(currentAverage.intValue - speedAverage.intValue) < 1) {
            
            if (currentAverage.intValue < masterAverage.intValue) {
                string = [NSString stringWithFormat:@"Comparing to other runs with similar distance and similar speed, your heart rate is lower than %@", masterAverage];
            }else{
                string = [NSString stringWithFormat:@"Comparing to other runs with similar distance and similar speed, your heart rate is lower than %@", masterAverage];
            }
        }else{
            if (currentAverage.intValue < masterAverage.intValue) {
                string = [NSString stringWithFormat:@"Comparing to other runs with similar distance, your heart rate is lower than %@", masterAverage];
            }else{
                string = [NSString stringWithFormat:@"Comparing to other runs with similar distance, your heart rate is lower than %@", masterAverage];
            }
        }
        
    }else{
        string = [NSString stringWithFormat:@"Unfortunately, we couldn't find any runs resembles this one. We can't provide you more data"];
    }
    
    
    return string;
}

-(void)beginAnalyzeHeartRate{
    
    NSString *string = [self generalHeartRateAnalysis];
    string = [string stringByAppendingString:[self relativeHeartRateAnalysis]];
}

#pragma mark - Analyze Elevation

-(NSString *)generalElevationAnalysis{
    
    NSString *string;
    
    NSNumber *elevationMax = [RunHelper getMaxNumber:elevation];
    NSNumber *elevationMin = [RunHelper getMinNumber:elevation];
    int elevationDiff = elevationMax.intValue - elevationMin.intValue;
    
    if (elevationDiff > 40)  {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"You ran on tough terrane today. The elevation different is %i", elevationDiff]];
        
        
        NSMutableArray *allSpeeds = [RunHelper calculateSpeed:[runHelper retrieveAllObjects]];
        NSNumber *averageSpeed = [RunHelper getAverageNumber:allSpeeds];
        if (currentSpeed > averageSpeed) {
            string = [string stringByAppendingString:[NSString stringWithFormat:@"You beat your speed average %0.2f (%@) during this hard workout", averageSpeed.floatValue, [MathController stringifyPaceFromSpeed:averageSpeed.floatValue]]];
        }
    }else{
        string = [NSString stringWithFormat:@"The elevation different %i in this run is not significant. Running on hilly trails will help you to improve your speed and endurence.", elevationDiff];
    }
    return string;
}

-(void)beginAnalyzeElevation{
    
    returnString = [self generalElevationAnalysis];
}

#pragma mark - Analyze Strides

-(void)beginAnalyzeStrides{
    
}

#pragma mark - Weather and Environment

-(void)beginAnalyzeWeatherEnvironment{
    
}

@end
