//
//  RunHelper.h
//  Run
//
//  Created by Yongyang Nie on 7/25/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Run.h"
#import "AppDelegate.h"

@interface RunHelper : NSObject

@property (readonly, strong, nonatomic, nonnull) NSManagedObjectContext *managedObjectContext;

+(NSString * __nullable)getAverageHeartbeatFromArray:(NSData * _Nonnull)data;

+(NSString * __nullable)getMaxHeartbeatFromArray:(NSData * _Nonnull)data;

+(NSString * __nullable )getAverageStride:(NSData * _Nonnull)data;

-(NSMutableArray * __nullable)retrieveAllObjects;

+(NSMutableArray * __nullable)calculateSpeed:(NSMutableArray * __nullable)array;

-(NSMutableArray * __nullable)retrieveObjectsWithDistanceRange:(int)min andMax:(int)max;

-(NSMutableArray * __nullable)calculateRowMeanMatrix:(NSMutableArray *__nullable)array;

////Math functions

+(NSNumber * _Nonnull)getMinNumber:(NSArray * _Nonnull)array;

+(NSNumber * _Nonnull)getMaxNumber:(NSArray * _Nonnull)array;

+(NSNumber * _Nonnull)getAverageNumber:(NSArray * _Nonnull)array;

@end
