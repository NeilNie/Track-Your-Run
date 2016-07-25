//
//  RunHelper.h
//  Run
//
//  Created by Yongyang Nie on 7/25/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Run.h"

@interface RunHelper : NSObject

+(NSString *)getAverageHeartbeatFromArray:(NSData *)data;

+(NSString *)getMaxHeartbeatFromArray:(NSData *)data;

+(NSString *)getAverageStride:(NSData *)data;

@end
