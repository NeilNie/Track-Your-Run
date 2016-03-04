//
//  HomeViewController.h
//  RunMaster
//
//  Created by Matt Luedke on 5/19/14.
//  Copyright (c) 2014 Matt Luedke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import "NewRunViewController.h"
#import "PastRunsViewController.h"
#import "RunCell.h"
#import "HealthKitManager.h"
#import "MathController.h"

@interface HomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, WCSessionDelegate>{
    NSTimer *timer;
}

@property (nonatomic, strong) Run *run;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UILabel *totalDistance;
@property (weak, nonatomic) IBOutlet UILabel *longestRun;
@property (weak, nonatomic) IBOutlet UILabel *BestPace;
@property (weak, nonatomic) IBOutlet UILabel *totalRuns;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *MapWidth;
@end
