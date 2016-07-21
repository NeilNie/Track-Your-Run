//
//  PastRunsViewController.h
//  
//
//  Created by Yongyang Nie on 3/7/16.
//
// (c) Yongyang Nie

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "RunDetailsViewController.h"
#import "Run.h"
#import "RunCell.h"
#import "MathController.h"
#import "SettingViewController.h"

@interface PastRunViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *runArray;
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
