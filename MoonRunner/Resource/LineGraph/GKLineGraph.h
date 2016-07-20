//
//  GKLineGraph.h
//  GraphKit
//
//  Copyright (c) 2014 Michal Konturek
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  2016 Yongyang Nie
//  Granted rights to use and edit this software
//

#import <UIKit/UIKit.h>

@protocol GKLineGraphDataSource;

@interface GKLineGraph : UIView

@property (nonatomic, assign) BOOL animated;
@property (nonatomic, assign) CFTimeInterval animationDuration;

@property (nonatomic, weak) IBOutlet id<GKLineGraphDataSource> dataSource;

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat margin;

@property (nonatomic, assign) NSInteger valueLabelCount;
//@property (nonatomic, strong) NSNumber *maxValue;

@property (nonatomic, assign) CGFloat *minValue;
@property (nonatomic, assign) BOOL startFromZero;

- (void)draw;
- (void)reset;

@end

@protocol GKLineGraphDataSource <NSObject>

- (NSInteger)numberOfLines;
- (UIColor *)colorForLineAtIndex:(NSInteger)index;
- (NSArray *)valuesForLineAtIndex:(NSInteger)index;

@optional
- (CFTimeInterval)animationDurationForLineAtIndex:(NSInteger)index;

- (NSString *)titleForLineAtIndex:(NSInteger)index;

@end
