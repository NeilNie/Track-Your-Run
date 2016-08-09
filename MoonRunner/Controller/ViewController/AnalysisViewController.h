//
//  AnalysisViewController.h
//  Run
//
//  Created by Yongyang Nie on 2/26/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MKFoundationKit/MKFoundationKit.h>

#import "GraphKit.h"
#import "MathController.h"
#import "Run.h"
#import "SettingViewController.h"
#import "PNChart.h"
#import "RunAnalyzer.h"

float distance;

@interface AnalysisViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, PNChartDelegate>{
    
    NSArray *TitleArray;
    NSMutableArray *Info;
    
    NSFetchRequest *fetchRequest;
    NSEntityDescription *entity;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Run *run;
@property (strong, nonatomic) RunAnalyzer *runAnalyzer;
@property (nonatomic, strong) PNLineChart *lineChart;


@property (nonatomic, strong) NSMutableArray *heartbeat;
@property (nonatomic, strong) NSArray *striderate;
@property (nonatomic, strong) NSArray *speed;
@property (nonatomic, strong) NSArray *elevation;
@property (nonatomic, strong) NSArray *data;

@property (weak, nonatomic) IBOutlet UIButton *heartButton;
@property (weak, nonatomic) IBOutlet UIButton *elevationButton;
@property (weak, nonatomic) IBOutlet UIButton *speedButton;
@property (weak, nonatomic) IBOutlet UIButton *strideButton;

@end
