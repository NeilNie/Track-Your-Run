//
//  RunDetailsViewController.h
//  RunMaster
//
//  Created by Matt Luedke on 5/19/14.
//  Copyright (c) 2014 Matt Luedke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "Run.h"
#import "MathController.h"
#import "Location.h"
#import "MulticolorPolylineSegment.h"
#import "SummaryTableViewCell.h"
#import "AnalysisViewController.h"
#import "SettingViewController.h"

#import "ButtonTableCell.h"
#import "InfoTableViewCell.h"
#import "BasicTableViewCell.h"
#import "RunHelper.h"
#import "WeatherTableViewCell.h"
#import "NewRunViewController.h"

@class Run;

@interface RunDetailsViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property BOOL saveNewRun;
@property (strong, nonatomic) Run *run;
@property (nonatomic, strong) NSMutableArray *masterArray;
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) NSArray *name;
@property (nonatomic, strong) NSArray *valueA;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *colorSegmentArray;

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UITableView *table;
@property (nonatomic, weak) IBOutlet UIButton *backButton;

@end
