//
//  IndoorRunViewController.h
//  Run
//
//  Created by Yongyang Nie on 2/21/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MapKit/MapKit.h>
#import "MathController.h"
#import "Run.h"
#import "Location.h"
#import "RunDetailsViewController.h"

@interface IndoorRunViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource>{
    NSTimer *timer;
    NSTimer *startTimer;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property int seconds;
@property float distance;

@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSMutableArray *splitsArray;
@property (nonatomic, strong) Run *run;

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *distLabel;
@property (nonatomic, weak) IBOutlet UILabel *paceLabel;
@property (nonatomic, weak) IBOutlet UILabel *calories;
@property (nonatomic, weak) IBOutlet UILabel *countDownLabel;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@property (nonatomic, weak) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *Label2;
@property (weak, nonatomic) IBOutlet UILabel *Label3;
@property (weak, nonatomic) IBOutlet UILabel *Label4;

@end
