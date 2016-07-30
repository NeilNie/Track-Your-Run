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

    [[HealthKitManager sharedManager] requestAuthorization];
    
    self.runArray = [[RunHelper new] retrieveAllObjects];
    [self setUpView];
    [self setUpGestures];
    [super viewDidLoad];
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
    
    if (self.runArray.count > 0) {
        return 5;
    }else{
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    InfoTableViewCell *cell = (InfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"RunCell"];
    
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

#pragma mark - MapView Delegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1100, 1100);
    [mapView setRegion:[mapView regionThatFits:region] animated:YES];
}

@end
