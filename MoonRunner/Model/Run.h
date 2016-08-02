//
//  Run.h
//  MoonRunner
//
//  Created by Matt Luedke on 6/10/14.
//  Copyright (c) 2014 Matt Luedke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location;

@interface Run : NSManagedObject

//data
@property (nonatomic, retain) NSNumber *feedback;
@property (nonatomic, retain) NSNumber *distance;
@property (nonatomic, retain) NSNumber *duration;
@property (nonatomic, retain) NSNumber *miliseconds;
@property (nonatomic, retain) NSDate * timestamp;

//arrays or dictionaries
@property (nonatomic, retain) NSData *weather;
@property (nonatomic, retain) NSData *heart_rate;
@property (nonatomic, retain) NSData *elevation;
@property (nonatomic, retain) NSData *stride_rate;
@property (nonatomic, retain) NSData *splits;
@property (nonatomic, retain) NSOrderedSet *locations;
@end

@interface Run (CoreDataGeneratedAccessors)

- (void)insertObject:(Location *)value inLocationsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLocationsAtIndex:(NSUInteger)idx;
- (void)insertLocations:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLocationsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLocationsAtIndex:(NSUInteger)idx withObject:(Location *)value;
- (void)replaceLocationsAtIndexes:(NSIndexSet *)indexes withLocations:(NSArray *)values;
- (void)addLocationsObject:(Location *)value;
- (void)removeLocationsObject:(Location *)value;
- (void)addLocations:(NSOrderedSet *)values;
- (void)removeLocations:(NSOrderedSet *)values;
@end
