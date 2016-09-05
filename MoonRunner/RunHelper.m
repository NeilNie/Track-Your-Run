//
//  RunHelper.m
//  Run
//
//  Created by Yongyang Nie on 7/25/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import "RunHelper.h"

@implementation RunHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        _managedObjectContext = delegate.managedObjectContext;
    }
    return self;
}

+(NSString *)getAverageStride:(NSData *)data{
    
    NSArray *stride = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (stride.count > 1) {
        int total = 0;
        int average = 0;
        for (int i = 0; i < stride.count; i++) {
            total += [[stride objectAtIndex:i] intValue];
        }
        average = total / stride.count;
        return [NSString stringWithFormat:@"%i", average];
    }else{
        return @"N/A";
    }
}

+(NSString *)getMaxHeartbeatFromArray:(NSData *)data{
    
    NSArray *HeartArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (HeartArray.count > 1) {
        int hightest = 0;
        for (int i = 0; i < HeartArray.count; i++) {
            if ([[HeartArray objectAtIndex:i] intValue] > hightest) {
                hightest = [[HeartArray objectAtIndex:i] intValue];
            }
        }
        return [NSString stringWithFormat:@"%i", hightest];
    }else{
        return @"N/A";
    }
    
}
+(NSString *)getAverageHeartbeatFromArray:(NSData *)data{
    
    NSArray *HeartArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (HeartArray.count > 1) {
        int total = 0;
        int average = 0;
        for (int i = 0; i < HeartArray.count; i++) {
            total += [[HeartArray objectAtIndex:i] intValue];
        }
        average = total / HeartArray.count;
        return [NSString stringWithFormat:@"%i", average];
    }else{
        return @"N/A";
    }
    
}

+(NSNumber *)getMinNumber:(NSArray *)array{
    
    NSNumber *min = [array objectAtIndex:0];
    for (NSNumber *x in array) {
        if (x < min) {
            min = x;
        }
    }
    return min;
}

+(NSNumber *)getMaxNumber:(NSArray *)array{
    
    NSNumber *max = [NSNumber numberWithInteger:0];
    for (NSNumber *x in array) {
        if (x > max) {
            max = x;
        }
    }
    return max;
}

+(NSNumber *)getAverageNumber:(NSArray *)array{
    
    if (array.count > 1) {
        float total = 0.0;
        float average = 0.0;
        for (int i = 0; i < array.count; i++) {
            total = total + [[array objectAtIndex:i] floatValue];
        }
        average = total / array.count;
        return [NSNumber numberWithFloat:average];
    }else{
        return @00;
    }
}

-(NSMutableArray *)calculateRowMeanMatrix:(NSMutableArray *)array{
    
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 0; i < array.count; i++) {
        Run *run = [array objectAtIndex:i];
        NSMutableArray *heartRates = [NSKeyedUnarchiver unarchiveObjectWithData:run.heart_rate];
        [result addObject:[RunHelper getAverageNumber:heartRates]];
    }
    return result;
}

-(NSMutableArray *)retrieveAllObjects{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Run" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
    return array;
}

+(NSMutableArray *)calculateSpeed:(NSMutableArray *)array{
    
    NSMutableArray *speedArray = [NSMutableArray array];
    
    for (int i = 0; i < array.count; i++) {
        Run *run = [array objectAtIndex:i];
        float speed = (run.distance.floatValue / 1609.344) / (run.duration.floatValue / 60.0 / 60.0);
        [speedArray addObject:[NSNumber numberWithFloat:speed]];
    }
    return speedArray;
}

-(NSMutableArray *)retrieveObjectsWithDistanceRange:(int)min andMax:(int)max{
    
    NSMutableArray *returnArray = [NSMutableArray array];
    NSMutableArray *runs = [self retrieveAllObjects];
    
    for (int i = 0; i < runs.count; i++) {
        Run *run = [runs objectAtIndex:i];
        if (run.distance.intValue > min && run.distance.intValue < max) {
            [returnArray addObject:run];
        }
    }
    
    return returnArray;
}

@end
