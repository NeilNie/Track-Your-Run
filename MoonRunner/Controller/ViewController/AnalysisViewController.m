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

#pragma mark - Public

- (void)setHeartArray:(NSArray *)heartArray
{
    if (heartArray.count > 0) {
        _heartbeat = heartArray;
    }
}

- (void)setSpeedArray:(NSArray *)speed
{
    if (speed.count > 0) {
        _speed = speed;
    }
}

- (void)_setupExampleGraph {
    
    self.labels = @[@"2001", @"2002", @"2006", @"2007"];
    
    self.graph.dataSource = self;
    self.graph.lineWidth = 3.0;
    
    self.graph.valueLabelCount = 6;
    
    [self.graph draw];
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

#pragma mark - Private

- (void)viewDidLoad {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.heartbeat.count; i++) {
        NSInteger st = [[self.heartbeat objectAtIndex:i] integerValue];
        [array addObject:[NSNumber numberWithInteger:st]];
    }
    self.data = @[array,
                  @[@100, @90, @110, @100, @120, @98, @122],
                  ];
    self.graph.dataSource = self;
    self.graph.lineWidth = 3.0;
    self.graph.valueLabelCount = 4;
    [self _setupExampleGraph];
    NSLog(@"%@", self.heartbeat);
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
