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
    return 50.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [TitleArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return nil;
}

#pragma mark - Public

- (void)setHeartArray:(NSArray *)heartArray{
    
    if (heartArray.count > 0) {
        _heartbeat = heartArray;
    }
}

- (void)setSpeedArray:(NSArray *)speed{
    
    if (speed.count > 0) {
        self.location = speed;
    }
}

- (void)setStrideArray:(NSArray *)stride{
    
    if (stride.count > 0) {
        self.striderate = stride;
    }
}

#pragma Private

- (void)_setupHeartrateGraph {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.heartbeat.count; i++) {
        NSInteger st = [[self.heartbeat objectAtIndex:i] integerValue];
        [array addObject:[NSNumber numberWithInteger:st]];
    }
    self.data = @[array,];
    
    self.graph.dataSource = self;
    self.graph.lineWidth = 3.0;
    
    self.graph.valueLabelCount = 4;
    
    [self.graph draw];
}

- (void)_setupStrideGraph {
    
    self.data = @[self.striderate,];
    
    self.labels = @[@"2001", @"2002", @"2006", @"2007"];
    
    self.graph.dataSource = self;
    self.graph.lineWidth = 3.0;
    
    self.graph.valueLabelCount = 4;
    
    [self.graph draw];
}

- (void)_setupSpeedGraph {
    
    NSMutableArray *speed = [[NSMutableArray alloc] initWithArray:[MathController getSpeedArrayFromLocations:self.location]];
    
    self.data = @[speed,];
    
    self.labels = @[@"2001", @"2002", @"2006", @"2007"];
    
    self.graph.dataSource = self;
    self.graph.lineWidth = 3.0;
    
    self.graph.valueLabelCount = 4;
    
    [self.graph draw];
}

- (void)_setupElevationGraph {
    
    self.data = @[self.elevation,];
    
    self.graph.dataSource = self;
    self.graph.lineWidth = 3.0;
    
    [self.graph draw];
}

-(void)setUpView{
    
    if (_heartbeat.count > 1) {
        self.heartButton.enabled = YES;
    }else{
        self.heartButton.enabled = NO;
    }
    if (_striderate.count > 1) {
        self.strideButton.enabled = YES;
    }else{
        self.strideButton.enabled = NO;
    }
    if (_elevation.count > 1) {
        self.elevationButton.enabled = YES;
    }else{
        self.elevationButton.enabled = NO;
    }
    if (_location.count > 1) {
        self.speedButton.enabled = YES;
    }else{
        self.speedButton.enabled = NO;
    }
}

#pragma mark - GKLineGraphDataSource

- (NSInteger)numberOfLines {
    return [self.data count];
}

- (UIColor *)colorForLineAtIndex:(NSInteger)index {
    id colors = @[[UIColor gk_turquoiseColor],
                  [UIColor gk_peterRiverColor],
                  ];
    return [colors objectAtIndex:index];
}

- (NSArray *)valuesForLineAtIndex:(NSInteger)index {
    return [self.data objectAtIndex:index];
}

- (CFTimeInterval)animationDurationForLineAtIndex:(NSInteger)index {
    return [[@[@1, @1.6] objectAtIndex:index] doubleValue];
}

- (NSString *)titleForLineAtIndex:(NSInteger)index {
    return nil;
}

#pragma mark - IBActions

-(IBAction)heartRate:(id)sender{
    
    [self _setupHeartrateGraph];
}
-(IBAction)strideRate:(id)sender{
    
    [self _setupStrideGraph];
}
-(IBAction)speed:(id)sender{
    
    [self _setupSpeedGraph];
}
-(IBAction)elevation:(id)sender{
    
    [self _setupElevationGraph];
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
    [self setUpView];
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
