//
//  RunAnalyzer.h
//  Run
//
//  Created by Yongyang Nie on 6/14/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Run.h"
#import "AppDelegate.h"
#import "RunHelper.h"
#import "MathController.h"

@interface RunAnalyzer : NSObject{
    
    RunHelper *runHelper;
    NSString *returnString;
    NSNumber *currentSpeed;
    NSMutableArray *elevation;
    NSMutableArray *heartRate;
}

-(instancetype _Nonnull)initWithRun:(Run *_Nonnull)run;
-(NSString * _Nonnull)returnAnalysisResult;
-(void)beginAnalyzeSpeed;
-(void)beginAnalyzeHeartRate;
-(void)beginAnalyzeElevation;
-(void)beginAnalyzeWeatherEnvironment;

@property (strong, nonatomic, nonnull) Run *run;

@end
