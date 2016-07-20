//
//  progressViewController.h
//  Run
//
//  Created by Yongyang Nie on 6/15/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GKLineGraph.h"
#import "GKBarGraph.h"
#import "UIColor+GraphKit.h"

@interface ProgressViewController : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet GKBarGraph *barGraph;
@property (weak, nonatomic) IBOutlet GKLineGraph *lineGraph;

@property (weak, nonatomic) NSArray *barData;
@property (weak, nonatomic) NSMutableArray *labels;

@end
