//
//  AnalysisViewController.h
//  Run
//
//  Created by Yongyang Nie on 2/26/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GraphKit.h"

@interface AnalysisViewController : UIViewController <GKLineGraphDataSource>

@property (nonatomic, weak) IBOutlet GKLineGraph *graph;

@property (nonatomic, strong) NSArray *heartbeat;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSArray *speed;
@property (nonatomic, strong) NSArray *labels;

@end
