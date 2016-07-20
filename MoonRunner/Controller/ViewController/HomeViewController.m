//
//  HomeViewController.m
//  RunMaster
//
//  Created by Matt Luedke on 5/19/14.
//  Copyright (c) 2014 Matt Luedke. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@property (strong, nonatomic) NSMutableArray *runArray;

@end

@implementation HomeViewController

-(void)viewDidLoad{

    if ([WCSession isSupported]) {
        NSLog(@"Activated");
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    
    areAdsRemoved = [[NSUserDefaults standardUserDefaults] boolForKey:@"areAdsRemoved"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (!areAdsRemoved) {
        self.bannerView.adUnitID = @"ca-app-pub-7942613644553368/1835128737";
        self.bannerView.rootViewController = self;
        [self.bannerView loadRequest:[GADRequest request]];
    }else{
        self.bannerView.hidden = YES;
    }
    [[HealthKitManager sharedManager] requestAuthorization];
    
    [self setUpCoreData];
    [self setUpView];
    [self setUpGestures];
    [super viewDidLoad];
    NSLog(@"did finish");
}

-(void)viewWillAppear:(BOOL)animated{
    
    self.MapWidth.constant = [[UIScreen mainScreen] bounds].size.width;
    MKCoordinateRegion mapRegion;
    mapRegion.center = self.map.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.010;
    mapRegion.span.longitudeDelta = 0.010;
    [self.map setRegion:mapRegion animated:YES];
    
    [super viewWillAppear:YES];
}

-(void)setUpView{
    
    float distance = 0.00;
    int INT = 0;
    for (int i = 0; i < self.runArray.count; i++) {
        Run *run = [self.runArray objectAtIndex:i];
        distance = distance + [run.distance intValue];
        INT = i;
    }
    self.totalDistance.text = [NSString stringWithFormat:@"%@", [MathController stringifyDistance:distance]];
    self.totalRuns.text = [NSString stringWithFormat:@"%i", INT + 1];
}

-(void)setUpGestures{
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]  initWithTarget:self action:@selector(didSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]  initWithTarget:self action:@selector(didSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeRight];
}

-(void)setUpCoreData{
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _managedObjectContext = delegate.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Run" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    self.runArray = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
    
}

- (void)didSwipe:(UISwipeGestureRecognizer*)swipe{
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:1 animations:^{
            self.MapWidth.constant = [[UIScreen mainScreen] bounds].size.width;
            [self.view layoutIfNeeded];
        }];
        
    }else if (swipe.direction == UISwipeGestureRecognizerDirectionLeft){
        
        [UIView animateWithDuration:1 animations:^{
            self.MapWidth.constant = 0;
            [self.view layoutIfNeeded];
        }];
    }
}

-(IBAction)showMenu:(id)sender{
    [kMainViewController showLeftViewAnimated:YES completionHandler:nil];
}

#pragma mark - WCSession Delegate

-(void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext{

    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"outdoorRun" sender:nil];
    });
}

#pragma mark - TableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RunCell *cell = (RunCell *)[tableView dequeueReusableCellWithIdentifier:@"RunCell"];
    
    if (self.runArray.count > 0) {
        Run *runObject = [self.runArray objectAtIndex:indexPath.row];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        cell.date.text = [formatter stringFromDate:runObject.timestamp];
        cell.distance.text = [MathController stringifyDistance:runObject.distance.floatValue];
        cell.pace.text = [MathController stringifyAvgPaceFromDist:runObject.distance.floatValue overTime:runObject.duration.intValue];

    }
    return cell;
}

#pragma mark - Navigation

- (IBAction)unwindToRed:(UIStoryboardSegue *)unwindSegue{}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *nextController = [segue destinationViewController];
    
    if ([nextController isKindOfClass:[PastRunViewController class]]) {
        ((PastRunViewController *) nextController).runArray = self.runArray;
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    
    }else if ([nextController isKindOfClass:[NewRunViewController class]]){
        NewRunViewController *controller = (NewRunViewController *)[segue destinationViewController];
        [controller setManagedObjectContext:self.managedObjectContext];
    }
}

#pragma mark - MapView Delegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1100, 1100);
    [mapView setRegion:[mapView regionThatFits:region] animated:YES];
}


@end
