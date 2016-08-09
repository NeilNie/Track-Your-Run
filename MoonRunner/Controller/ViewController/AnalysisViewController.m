//
//  AnalysisViewController.m
//  Run
//
//  Created by Yongyang Nie on 2/26/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import "AnalysisViewController.h"

@interface AnalysisViewController ()

@end

@implementation AnalysisViewController

#pragma mark - UITableView Controller

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [TitleArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableCell" forIndexPath:indexPath];
    UILabel *title = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *text = (UILabel *)[cell.contentView viewWithTag:2];
    title.text = TitleArray[indexPath.row];
    text.text = [Info objectAtIndex:indexPath.row];
    return cell;
}

#pragma PNChart Delegates

-(void)userClickedOnLineKeyPoint:(CGPoint)point lineIndex:(NSInteger)lineIndex pointIndex:(NSInteger)pointIndex{}

#pragma Private

-(NSMutableArray *)getXArray:(NSArray *)array{
    
    NSMutableArray *returnArray = [NSMutableArray array];
    
    for (int i = 0; i < array.count; i++) {
        [returnArray addObject:[NSString stringWithFormat:@"%i", i]];
    }
    
    return returnArray;
}

-(void)setUpGraphs:(NSArray *)array{
    
    self.lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 35, self.view.frame.size.width, 250.0)];
    self.lineChart.yLabelFormat = @"%1.1f";
    self.lineChart.backgroundColor = [UIColor clearColor];
    [self.lineChart setXLabels:[self getXArray:array]];
    self.lineChart.showCoordinateAxis = YES;
    self.lineChart.showYGridLines = YES;
}

-(void)graphSpeed{
    
    NSArray * data01Array = self.speed;
    PNLineChartData *data01 = [PNLineChartData new];
    data01.dataTitle = @"Speed";
    data01.color = PNDarkBlue;
    data01.alpha = 0.3f;
    data01.lineWidth = 4.0f;
    data01.itemCount = data01Array.count;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [data01Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    if (self.lineChart.chartData == nil) {
        [self.lineChart setChartData:[NSArray arrayWithObject:data01]];
    }else{
        [self.lineChart.chartData arrayByAddingObject:data01];
    }
    self.lineChart.delegate = self;
    [self.lineChart strokeChart];
    [self.view addSubview:self.lineChart];
    [self addChartLengend];
}

-(void)graphHeartRate{
    
    NSArray * data01Array = self.heartbeat;
    PNLineChartData *data01 = [PNLineChartData new];
    data01.dataTitle = @"Heart Rate";
    data01.color = PNRed;
    data01.alpha = 0.3f;
    data01.lineWidth = 4.0f;
    data01.itemCount = data01Array.count;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [data01Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    [self.lineChart.chartData arrayByAddingObject:data01];
    [self.lineChart strokeChart];
    self.lineChart.delegate = self;
    [self.view addSubview:self.lineChart];
    [self addChartLengend];
}

-(void)graphStrideRate{
    
    NSArray * data01Array = self.striderate;
    PNLineChartData *data01 = [PNLineChartData new];
    data01.dataTitle = @"Stride Rate";
    data01.color = PNGreen;
    data01.alpha = 0.3f;
    data01.lineWidth = 4.0f;
    data01.itemCount = data01Array.count;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [data01Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    [self.lineChart.chartData arrayByAddingObject:data01];
    [self.lineChart strokeChart];
    self.lineChart.delegate = self;
    [self.view addSubview:self.lineChart];
    [self addChartLengend];
}


-(void)graphElevation{
    
    NSArray * data01Array = self.elevation;
    PNLineChartData *data01 = [PNLineChartData new];
    data01.dataTitle = @"Elevation";
    data01.color = PNBrown;
    data01.alpha = 0.3f;
    data01.lineWidth = 4.0f;
    data01.itemCount = data01Array.count;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [data01Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    [self.lineChart.chartData arrayByAddingObject:data01];
    [self.lineChart strokeChart];
    self.lineChart.delegate = self;
    [self.view addSubview:self.lineChart];
    [self addChartLengend];
}

-(void)addChartLengend{
    
    self.lineChart.legendStyle = PNLegendItemStyleStacked;
    self.lineChart.legendFont = [UIFont boldSystemFontOfSize:12.0f];
    self.lineChart.legendFontColor = [UIColor darkGrayColor];
    
    UIView *legend = [self.lineChart getLegendWithMaxWidth:200];
    [legend setFrame:CGRectMake(self.lineChart.frame.origin.x + 16, self.lineChart.frame.origin.y + 270, legend.frame.size.width, legend.frame.size.width)];
    [self.view addSubview:legend];
}

-(void)setUpData{
    
    TitleArray = [NSMutableArray array];
    Info = [NSMutableArray array];
    
    self.heartbeat = [NSMutableArray array];
    self.striderate = [NSKeyedUnarchiver unarchiveObjectWithData:self.run.stride_rate];
    self.elevation = [NSKeyedUnarchiver unarchiveObjectWithData:self.run.elevation];
    
    if (self.run.locations.array.count < 30) {
        self.speed = [MathController getSpeedArrayFromLocations:self.run.locations.array];
    }else{
        self.speed = [MathController getLimitedSpeedArrayFromLocations:self.run.locations.array];
    }
    
    NSMutableArray *values = [NSKeyedUnarchiver unarchiveObjectWithData:self.run.heart_rate];
    
    for (int i = 0; i < values.count; i++) {
        NSInteger st = [[values objectAtIndex:i] integerValue];
        [_heartbeat addObject:[NSNumber numberWithInteger:st]];
    }
}

-(void)setUpView{
    
    if (_heartbeat.count > 1) {
        
        self.heartButton.enabled = YES;
        //[TitleArray addObject:@"Heart rate"];
        //[Info addObject:[self analyzeHeartrate]];
    }else{
        self.heartButton.enabled = NO;
    }
    
    if (_striderate.count > 1) {
        
        self.strideButton.enabled = YES;
        //[TitleArray addObject:@"Stride rate"];
    }else{
        self.strideButton.enabled = NO;
    }
    
    if (_elevation.count > 1) {
        
        self.elevationButton.enabled = YES;
        //[TitleArray addObject:@"Elevation"];
    }else{
        self.elevationButton.enabled = NO;
    }
    
    if (_speed.count > 1) {
        
        self.speedButton.enabled = YES;
        //[TitleArray addObject:@"Speed"];
        //[Info addObject:[self analyzeSpeed]];
    }else{
        self.speedButton.enabled = NO;
    }
}

#pragma mark - IBActions

-(IBAction)heartRate:(id)sender{
    
//    [self _setupGraphWithArray:_heartbeat];
}
-(IBAction)strideRate:(id)sender{
    
//    [self _setupGraphWithArray:_striderate];
}
-(IBAction)speed:(id)sender{
    
//    [self _setupGraphWithArray:_speed];
}
-(IBAction)elevation:(id)sender{
    
//    [self _setupGraphWithArray:_elevation];
}

-(void)setupAnalysisData{
    
    self.runAnalyzer = [[RunAnalyzer alloc] initWithRun:self.run];
    [self.runAnalyzer beginAnalyzeSpeed];
    NSString *string = [self.runAnalyzer returnAnalysisResult];
    [self.runAnalyzer beginAnalyzeElevation];
    NSString *elevation = [self.runAnalyzer returnAnalysisResult];
    [self.runAnalyzer beginAnalyzeHeartRate];
    NSString *heartRate = [self.runAnalyzer returnAnalysisResult];
    
    TitleArray = [NSArray arrayWithObjects:@"Speed", @"Heart Rate", @"Elevation", nil];
    Info = [NSMutableArray array];
    [Info addObject:string];
    [Info addObject:heartRate];
    [Info addObject:elevation];
    
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    
//    //fetch all run data
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:@"Run" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [self setUpData];
    [self setUpView];
    [self setUpGraphs:self.speed];
    [self graphSpeed];
    [self setupAnalysisData];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
