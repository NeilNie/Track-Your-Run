//
//  progressViewController.m
//  Run
//
//  Created by Yongyang Nie on 6/15/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import "ProgressViewController.h"

@interface ProgressViewController ()

@end

@implementation ProgressViewController

#pragma mark - GKBarGraphDataSource

- (NSInteger)numberOfBars {
    return [self.barData count];
}

- (NSNumber *)valueForBarAtIndex:(NSInteger)index {
    return [self.barData objectAtIndex:index];
}

- (UIColor *)colorForBarAtIndex:(NSInteger)index {
    
    return [UIColor gk_pumpkinColor];
}

- (CFTimeInterval)animationDurationForBarAtIndex:(NSInteger)index {
    
    return (1.0);
}

- (NSString *)titleForBarAtIndex:(NSInteger)index {
    return [self.labels objectAtIndex:index];
}

#pragma mark - Private

-(IBAction)showMenu:(id)sender{
    [kMainViewController showLeftViewAnimated:YES completionHandler:nil];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    
    
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
