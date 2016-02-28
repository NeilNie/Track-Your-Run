//
//  Math.h
//  Run
//
//  Created by Yongyang Nie on 2/18/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Math : NSObject

+ (NSString *)stringifyDistance:(float)meters;

+ (NSString *)stringifySecondCount:(int)seconds usingLongFormat:(BOOL)longFormat;

+ (NSString *)stringifyAvgPaceFromDist:(float)meters overTime:(int)seconds;

+ (NSString *)stringifyStrideRateFromSteps:(int)steps overTime:(int)seconds;

@end
