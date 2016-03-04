//
//  AnalysisViewController.h
//  Run
//
//  Created by Yongyang Nie on 2/26/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GraphKit.h"
#import "MathController.h"

@interface AnalysisViewController : UIViewController <GKLineGraphDataSource, UITableViewDataSource, UITableViewDelegate>{
    
    NSArray *TitleArray;
    NSArray *Info;
}

@property (nonatomic, weak) IBOutlet GKLineGraph *graph;

@property (nonatomic, strong) NSArray *heartbeat;
@property (nonatomic, strong) NSArray *striderate;
@property (nonatomic, strong) NSArray *location;
@property (nonatomic, strong) NSArray *elevation;

@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, strong) NSArray *data;

@property (weak, nonatomic) IBOutlet UIButton *heartButton;
@property (weak, nonatomic) IBOutlet UIButton *elevationButton;
@property (weak, nonatomic) IBOutlet UIButton *speedButton;
@property (weak, nonatomic) IBOutlet UIButton *strideButton;

- (void)setSpeedArray:(NSArray *)speed;

@end
