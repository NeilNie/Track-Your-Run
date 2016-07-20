//
//  RunDetailsViewController.h
//  RunMaster
//
//  Created by Matt Luedke on 5/19/14.
//  Copyright (c) 2014 Matt Luedke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Run.h"
#import "MathController.h"
#import "Location.h"
#import "MulticolorPolylineSegment.h"
#import "SplitCell.h"
#import "AnalysisViewController.h"
#import "SettingViewController.h"

@class Run;

@import GoogleMobileAds;

@interface RunDetailsViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>{
    NSMutableArray *masterArray;
    NSArray *array;
    NSArray *name;
    NSArray *valueA;
}

@property (weak, nonatomic) IBOutlet UIImageView *mapSnapShot;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Run *run;
@property (strong, nonatomic) NSArray *colorSegmentArray;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UITableView *table;

@property (weak, nonatomic) IBOutlet GADBannerView  *bannerView;

@end
