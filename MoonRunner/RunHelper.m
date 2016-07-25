//
//  RunHelper.m
//  Run
//
//  Created by Yongyang Nie on 7/25/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import "RunHelper.h"

@implementation RunHelper

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

@end
