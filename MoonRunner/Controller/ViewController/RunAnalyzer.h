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
    NSMutableString *returnString;
    RunHelper *runHelper;
}

//-(NSString * _Nonnull)returnAnalysisResult;
-(void)beginAnalyzeSpeed;
-(void)beginAnalyzeHeartRate;
-(void)beginAnalyzeElevation;
-(void)beginAnalyzeHeartStrides;

@property (strong, nonatomic, nonnull) Run *run;
@property (strong, nonatomic, nonnull) NSMutableArray *runData;

@end
