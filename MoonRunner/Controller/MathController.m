//
//  MathController.m
//  RunMaster
//
//  Created by Matt Luedke on 5/20/14.
//  Copyright (c) 2014 Matt Luedke. All rights reserved.
//

#import "MathController.h"
#import "Location.h"
#import "MulticolorPolylineSegment.h"

static bool const isMetric = NO;
static float const metersInKM = 1000;
static float const metersInMile = 1609.344;
static const int idealSmoothReachSize = 33; // about 133 locations/mi

@implementation MathController

+ (NSString *)stringifyDistance:(float)meters {
    
    float unitDivider;
    NSString *unitName;
    
    // metric
    if (isMetric) {
        
        unitName = @"km";
        // to get from meters to kilometers divide by this
        unitDivider = metersInKM;
    // U.S.
    } else {
        
        unitName = @"mi";
        // to get from meters to miles divide by this
        unitDivider = metersInMile;
    }
    
    return [NSString stringWithFormat:@"%.2f", (meters / unitDivider)]; //unitName
}

+ (NSString *)stringifySecondCount:(int)seconds usingLongFormat:(BOOL)longFormat {
    
    int remainingSeconds = seconds;
    
    int hours = remainingSeconds / 3600;
    
    remainingSeconds = remainingSeconds - hours * 3600;
    
    int minutes = remainingSeconds / 60;
    
    remainingSeconds = remainingSeconds - minutes * 60;
    
    if (longFormat) {
        if (hours > 0) {
            return [NSString stringWithFormat:@"%i:%i:%i", hours, minutes, remainingSeconds];
            
        } else if (minutes > 0) {
            return [NSString stringWithFormat:@"%i:%i", minutes, remainingSeconds];
            
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
    
    return [NSString stringWithFormat:@"%i:%02i %@", paceMin, paceSec, unitName];
}

+(NSString *)stringifyPaceFromSpeed:(float)speed{
    
    int minute = 60 / speed;
    float seconds = 60 / speed - minute;
    int actualSeconds = seconds * 60;
    NSString *returnString = [NSString stringWithFormat:@"%i:%im/mi", minute, actualSeconds];
    return returnString;
}

+ (NSString *)stringifyCaloriesFromDist:(float)meters{
    
    float unitDivider;
    NSString *unitName;
    
    if (isMetric) {
        
        unitName = @"km";
        unitDivider = metersInKM;
        
    } else {
        
        //unitName = @"mi";
        unitDivider = metersInMile;
    }
    
    NSNumber *miles = [NSNumber numberWithFloat:(meters / unitDivider) * 0.63 * 150];
    return [NSString stringWithFormat:@"%i", miles.intValue];

}

+ (NSString *)stringifyStrideRateFromSteps:(int)steps overTime:(int)seconds{
    
    
    return [NSString stringWithFormat:@"%i", steps / seconds * 60];
}

+ (NSArray *)getSpeedArrayFromLocations:(NSArray *)array;{
    
    if (array.count <= 1){
            return nil;
    }
        
    // make array of all speeds
    NSMutableArray *rawSpeeds = [NSMutableArray array];

    for (int i = 1; i < array.count; i++) {
        Location *firstLoc = [array objectAtIndex:(i-1)];
        Location *secondLoc = [array objectAtIndex:i];
            
        CLLocation *firstLocCL = [[CLLocation alloc] initWithLatitude:firstLoc.latitude.doubleValue longitude:firstLoc.longitude.doubleValue];
        CLLocation *secondLocCL = [[CLLocation alloc] initWithLatitude:secondLoc.latitude.doubleValue longitude:secondLoc.longitude.doubleValue];
            
        double distance = [secondLocCL distanceFromLocation:firstLocCL];
        double time = [secondLoc.timestamp timeIntervalSinceDate:firstLoc.timestamp];
        double speed = distance/time;
            
        [rawSpeeds addObject:[NSNumber numberWithDouble:speed]];
    }
    return rawSpeeds;
}

+ (NSArray *)getLimitedSpeedArrayFromLocations:(NSArray *)array{

    // make array of all speeds
    NSMutableArray *rawSpeeds = (NSMutableArray *)[MathController getSpeedArrayFromLocations:array];
    
    //return array
    NSMutableArray *returnArray = [NSMutableArray array];
    
    if (rawSpeeds.count > 30 && rawSpeeds.count < 60) {
        
        //get first 10 object in array
        for (int i = 0; i < 10; i++) {
            [returnArray addObject:[rawSpeeds objectAtIndex:i]];
        }
        
        //get middle 10 objects in array
        for (int x = (int) rawSpeeds.count / 2 - 5; x < rawSpeeds.count / 2 + 5; x++) {
            [returnArray addObject:[rawSpeeds objectAtIndex:x]];
        }
        
        //get last 10 objects in array.
        for (int y = (int) rawSpeeds.count - 10; y < rawSpeeds.count; y++) {
            [returnArray addObject:[rawSpeeds objectAtIndex:y]];
        }
    }else{
        
        //how many numbers do I have to add together to calculate the average.
        int numberOfnumbers = (int) (rawSpeeds.count + 1 ) / 30;
        
        for (int i = 0; i < rawSpeeds.count; i = i + numberOfnumbers) {
            
            float sum = 0.0f;
            for (int x = i; x < i + numberOfnumbers; x++) {
                sum = sum + [[rawSpeeds objectAtIndex:x] floatValue];
            }
            float average = sum / numberOfnumbers;
            [returnArray addObject:[NSNumber numberWithFloat:average]];
        }
    }
    return returnArray;
}

+ (NSArray *)colorSegmentsForLocations:(NSArray *)locations
{
    if (locations.count == 1){
        Location *loc      = [locations firstObject];
        CLLocationCoordinate2D coords[2];
        coords[0].latitude      = loc.latitude.doubleValue;
        coords[0].longitude     = loc.longitude.doubleValue;
        coords[1].latitude      = loc.latitude.doubleValue;
        coords[1].longitude     = loc.longitude.doubleValue;
        
        MulticolorPolylineSegment *segment = [MulticolorPolylineSegment polylineWithCoordinates:coords count:2];
        segment.color = [UIColor blackColor];
        return @[segment];
    }    
    
    // make array of all speeds
    NSMutableArray *rawSpeeds = [NSMutableArray array];
    
    NSLog(@"%@", rawSpeeds);
    
    for (int i = 1; i < locations.count; i++) {
        Location *firstLoc = [locations objectAtIndex:(i-1)];
        Location *secondLoc = [locations objectAtIndex:i];
        
        CLLocation *firstLocCL = [[CLLocation alloc] initWithLatitude:firstLoc.latitude.doubleValue longitude:firstLoc.longitude.doubleValue];
        CLLocation *secondLocCL = [[CLLocation alloc] initWithLatitude:secondLoc.latitude.doubleValue longitude:secondLoc.longitude.doubleValue];
        
        double distance = [secondLocCL distanceFromLocation:firstLocCL];
        double time = [secondLoc.timestamp timeIntervalSinceDate:firstLoc.timestamp];
        double speed = distance/time;
        
        [rawSpeeds addObject:[NSNumber numberWithDouble:speed]];
    }
    
    // smooth the raw speeds
    NSMutableArray *smoothSpeeds = [NSMutableArray array];
    
    for (int i = 0; i < rawSpeeds.count; i++) {
        
        // set to ideal size
        int lowerBound = i - idealSmoothReachSize / 2;
        int upperBound = i + idealSmoothReachSize / 2;
        
        // scale back reach as necessary
        if (lowerBound < 0) {
            lowerBound = 0;
        }
        
        if (upperBound > ((int)rawSpeeds.count - 1)) {
            upperBound = (int)rawSpeeds.count - 1;
        }
        
        // define range for average
        NSRange range;
        range.location = lowerBound;
        range.length = upperBound - lowerBound;
        
        // get values to average
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        NSArray *relevantSpeeds = [rawSpeeds objectsAtIndexes:indexSet];
        
        double total = 0.0;
        
        for (NSNumber *speed in relevantSpeeds) {
            total += speed.doubleValue;
        }
        
        double smoothAverage = total / (double)(upperBound - lowerBound);
        
        [smoothSpeeds addObject:[NSNumber numberWithDouble:smoothAverage]];
    }
    
    // sort the smoothed speeds
    NSArray *sortedArray = [smoothSpeeds sortedArrayUsingSelector:@selector(compare:)];
    
    // find median
    double medianSpeed = ((NSNumber *)[sortedArray objectAtIndex:(locations.count/2)]).doubleValue;
    
    // RGB for red (slowest)
    CGFloat r_red = 1.0f;
    CGFloat r_green = 20/255.0f;
    CGFloat r_blue = 44/255.0f;
    
    // RGB for yellow (middle)
    CGFloat y_red = 1.0f;
    CGFloat y_green = 215/255.0f;
    CGFloat y_blue = 0.0f;
    
    // RGB for green (fastest)
    CGFloat g_red = 0.0f;
    CGFloat g_green = 146/255.0f;
    CGFloat g_blue = 78/255.0f;
    
    NSMutableArray *colorSegments = [NSMutableArray array];
    
    for (int i = 1; i < locations.count; i++) {
        Location *firstLoc = [locations objectAtIndex:(i-1)];
        Location *secondLoc = [locations objectAtIndex:i];
        
        CLLocationCoordinate2D coords[2];
        coords[0].latitude = firstLoc.latitude.doubleValue;
        coords[0].longitude = firstLoc.longitude.doubleValue;
        
        coords[1].latitude = secondLoc.latitude.doubleValue;
        coords[1].longitude = secondLoc.longitude.doubleValue;
        
        NSNumber *speed = [smoothSpeeds objectAtIndex:(i-1)];
        UIColor *color;
        
        // between red and yellow
        if (speed.doubleValue < medianSpeed) {
            NSUInteger index = [sortedArray indexOfObject:speed];
            double ratio = (int)index / ((int)locations.count/2.0);
            CGFloat red = r_red + ratio * (y_red - r_red);
            CGFloat green = r_green + ratio * (y_green - r_green);
            CGFloat blue = r_blue + ratio * (y_blue - r_blue);
            color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
            
        // between yellow and green
        } else {
            NSUInteger index = [sortedArray indexOfObject:speed];
            double ratio = ((int)index - (int)locations.count/2.0) / ((int)locations.count/2.0);
            CGFloat red = y_red + ratio * (g_red - y_red);
            CGFloat green = y_green + ratio * (g_green - y_green);
            CGFloat blue = y_blue + ratio * (g_blue - y_blue);
            color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
        }
        
        MulticolorPolylineSegment *segment = [MulticolorPolylineSegment polylineWithCoordinates:coords count:2];
        segment.color = color;
        
        [colorSegments addObject:segment];
    }
    
    return colorSegments;
}

@end
