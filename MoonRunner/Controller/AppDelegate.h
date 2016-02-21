//
//  AppDelegate.h
//  RunmasterGeneral
//
//  Created by Matt Luedke on 5/18/14.
//  Copyright (c) 2014 Matt Luedke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import "Run.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, WCSessionDelegate>{
    HKHealthStore *healthStore;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) Run *run;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
