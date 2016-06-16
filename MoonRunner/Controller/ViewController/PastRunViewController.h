//
//  PastRunsViewController.h
//  
//
//  Created by Yongyang Nie on 3/7/16.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "RunDetailsViewController.h"
#import "Run.h"
#import "RunCell.h"
#import "MathController.h"
#import "SettingViewController.h"

@import GoogleMobileAds;

@interface PastRunViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *runArray;
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet GADBannerView  *bannerView;
@end
