//
//  Math.m
//  Run
//
//  Created by Yongyang Nie on 2/18/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import "Math.h"
#import "Location.h"

@implementation Math

static bool const isMetric = NO;
static float const metersInKM = 1000;
static float const metersInMile = 1609.344;
//static const int idealSmoothReachSize = 33; // about 133 locations/mi

+ (NSString *)stringifyDistance:(float)meters {
    
    float unitDivider;
    
    // metric
    unitDivider = metersInMile;
    
    return [NSString stringWithFormat:@"%.2f", (meters / unitDivider)];
}

+ (NSString *)stringifySecondCount:(int)seconds usingLongFormat:(BOOL)longFormat {
    
    int remainingSeconds = seconds;
    
    int hours = remainingSeconds / 3600;
    
    remainingSeconds = remainingSeconds - hours * 3600;
    
    int minutes = remainingSeconds / 60;
    
    remainingSeconds = remainingSeconds - minutes * 60;
    
    if (longFormat) {
        if (hours > 0) {
            return [NSString stringWithFormat:@"%ihr %imin %isec", hours, minutes, remainingSeconds];
            
        } else if (minutes > 0) {
            return [NSString stringWithFormat:@"%imin %isec", minutes, remainingSeconds];
            
        } else {
            return [NSString stringWithFormat:@"%isec", remainingSeconds];
        }
    } else {
        if (hours > 0) {
            return [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, remainingSeconds];
            
        } else if (minutes > 0) {
            return [NSString stringWithFormat:@"%02i:%02i", minutes, remainingSeconds];
            
        } else {
            return [NSString stringWithFormat:@"00:%02i", remainingSeconds];
        }
    }
}

+ (NSString *)stringifyAvgPaceFromDist:(float)meters overTime:(int)seconds
{
    if (seconds == 0 || meters == 0) {
        return @"0";
    }
    
    float avgPaceSecMeters = seconds / meters;
    
    float unitMultiplier;
    NSString *unitName;
    
    // metric
    if (isMetric) {
        
        unitName = @"m/km";
        
        // to get from meters to kilometers divide by this
        unitMultiplier = metersInKM;
        
        // U.S.
    } else {
        
        unitName = @"m/mi";
        
        // to get from meters to miles divide by this
        unitMultiplier = metersInMile;
    }
    
    int paceMin = (int) ((avgPaceSecMeters * unitMultiplier) / 60);
    int paceSec = (int) (avgPaceSecMeters * unitMultiplier - (paceMin*60));
    
    return [NSString stringWithFormat:@"%i:%02i", paceMin, paceSec];
}

+ (NSString *)stringifyStrideRateFromSteps:(int)steps overTime:(int)seconds{
    
    return [NSString stringWithFormat:@"%i", steps / seconds * 60];
}


@end
