//
//  RunDetailsViewController.h
//  RunMaster
//
//  Created by Matt Luedke on 5/19/14.
//  Copyright (c) 2014 Matt Luedke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PastRunsViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *runArray;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
