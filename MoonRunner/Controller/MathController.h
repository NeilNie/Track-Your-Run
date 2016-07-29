//
//  MathController.h
//  RunMaster
//
//  Created by Matt Luedke on 5/20/14.
//  Copyright (c) 2014 Matt Luedke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MathController : NSObject

+ (NSString *)stringifyDistance:(float)meters;

+ (NSString *)stringifySecondCount:(int)seconds usingLongFormat:(BOOL)longFormat;

+ (NSString *)stringifyAvgPaceFromDist:(float)meters overTime:(int)seconds;

+ (NSArray *)colorSegmentsForLocations:(NSArray *)locations;

+ (NSString *)stringifyCaloriesFromDist:(float)meters;

+ (NSString *)stringifyStrideRateFromSteps:(int)steps overTime:(int)seconds;

+ (NSArray *)getSpeedArrayFromLocations:(NSArray *)array;

+ (NSArray *)getLimitedSpeedArrayFromLocations:(NSArray *)array;

+(NSString *)stringifyPaceFromSpeed:(float)speed;

@end
