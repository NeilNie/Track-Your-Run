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

-(instancetype)init{
    
    self = [super init];
    if (self) {
        _run = [[Run alloc] init];
    }
    return self;
}

-(NSString * _Nonnull)returnAnalysisResult{
    return @"";
}

#pragma mark - Analyze Speed

-(void)beginAnalyzeSpeed{
    
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
