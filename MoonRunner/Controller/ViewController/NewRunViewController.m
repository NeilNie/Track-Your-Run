//
//  NewRunViewController.m
//  RunMaster
//
//  Created by Matt Luedke on 5/19/14.
//  Copyright (c) 2014 Matt Luedke. All rights reserved.
//

#import "NewRunViewController.h"

int it;

static NSString * const detailSegueName = @"NewRunDetails";

@interface NewRunViewController () 

@end

@implementation NewRunViewController

#pragma mark - Lifecycle

-(void)viewDidLoad {
    
    //modify view
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    self.seconds = 0;
    self.distance = 0;
    self.miliseconds = 0;
    it = 3;
    
    self.locations = [NSMutableArray array];
    self.splitsArray = [NSMutableArray array];
    self.strides = [NSMutableArray array];
    self.altitude = [NSMutableArray array];
    self.heartRate = [NSMutableArray array];
    
    // initialize the timer
    startTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]  initWithTarget:self action:@selector(didSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]  initWithTarget:self action:@selector(didSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeRight];
    
    if ([WCSession isSupported]) {
        NSLog(@"Activated");
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        
    }else{
        NSLog(@"not supported");
    }
    
    self.MapWidth.constant = [[UIScreen mainScreen] bounds].size.width;
    MKCoordinateRegion mapRegion;
    mapRegion.center = self.mapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.015;
    mapRegion.span.longitudeDelta = 0.015;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView setRegion:mapRegion animated:YES];
    });
    
    areAdsRemoved = [[NSUserDefaults standardUserDefaults] boolForKey:@"areAdsRemoved"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (!areAdsRemoved) {
        self.bannerView.adUnitID = @"ca-app-pub-7942613644553368/1835128737";
        self.bannerView.rootViewController = self;
        [self.bannerView loadRequest:[GADRequest request]];
    }else{
        self.bannerView.hidden = YES;
    }
    
    [super viewDidLoad];
}

- (void)didSwipe:(UISwipeGestureRecognizer*)swipe{
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.8 animations:^{
            self.MapWidth.constant = [[UIScreen mainScreen] bounds].size.width;
            [self.view layoutIfNeeded];
        }];
        
    }else if (swipe.direction == UISwipeGestureRecognizerDirectionLeft){
        
        [UIView animateWithDuration:0.8 animations:^{
            self.MapWidth.constant = 0;
            [self.view layoutIfNeeded];
        }];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer invalidate];
    [timeTimer invalidate];
}

#pragma mark - IBActions

- (IBAction)stopPressed:(id)sender
{
    [Pedometer stopPedometerUpdates];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save", @"Discard", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
    
}
-(IBAction)splitPressed:(id)sender{
    
    NSDictionary *dict = @{@"distance": [MathController stringifyDistance:self.distance],
                           @"time": [MathController stringifySecondCount:self.seconds usingLongFormat:NO],
                           @"heart": @"N/A bmp",
                           @"mili": [NSString stringWithFormat:@"%i", self.miliseconds]};
    [self.splitsArray addObject:dict];
    self.distance = 0;
    self.seconds = 0;
    [self.timeLabel setText:@"00:00"];
    [self.distLabel setText:@"0.00mi"];
    NSLog(@"splits: %@", self.splitsArray);
    
    //modify view
    [self.table reloadData];
    [UIView animateWithDuration:1 animations:^{
        self.MapWidth.constant = 0;
    }];
    
    [self.mapView removeOverlays:self.mapView.overlays];
}

#pragma mark - Private

-(void)countDown{
    
    it = it - 1;
    self.countDownLabel.text = [NSString stringWithFormat:@"%i", it];
    if (it == 2) {
        [self startLocationUpdates];
    }
    if (it == 0) {

        [startTimer invalidate];
        [self startPedometer];
        timer = [NSTimer scheduledTimerWithTimeInterval:(2.0) target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
        timeTimer = [NSTimer scheduledTimerWithTimeInterval:(0.1) target:self selector:@selector(timerCount) userInfo:nil repeats:YES];
        
        self.countDownLabel.hidden = YES;
        self.cover.hidden = YES;
    }
}

-(void)startPedometer{
    
    Pedometer = [[CMPedometer alloc] init];
    [Pedometer startPedometerUpdatesFromDate:[NSDate dateWithTimeIntervalSinceNow:0] withHandler:^(CMPedometerData *pedometerData, NSError *error) {
        if (!error) {
            [self.strides addObject:[MathController stringifyStrideRateFromSteps:pedometerData.numberOfSteps.intValue overTime:self.seconds]];
        }else{
            NSLog(@"%@", error);
        }
    }];
    
    [altimeter startRelativeAltitudeUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAltitudeData * _Nullable altitudeData, NSError * _Nullable error) {
        if (!error) {
            [self.altitude addObject:altitudeData.relativeAltitude];
        }else{
            NSLog(@"altitude error");
        }
    }];
}

- (void)saveRun{
    
    Run *newRun = [NSEntityDescription insertNewObjectForEntityForName:@"Run" inManagedObjectContext:self.managedObjectContext];
    newRun.distance = [NSNumber numberWithFloat:self.distance];
    newRun.duration = [NSNumber numberWithInt:self.seconds];
    newRun.timestamp = [NSDate date];
    newRun.splits = [NSKeyedArchiver archivedDataWithRootObject:self.splitsArray];
    newRun.stride_rate = [NSKeyedArchiver archivedDataWithRootObject:self.strides];
    newRun.heart_rate = [NSKeyedArchiver archivedDataWithRootObject:self.heartRate];
    newRun.miliseconds = [NSNumber numberWithInt:self.miliseconds];
    newRun.speed = [NSNumber numberWithFloat:self.distance / self.seconds];
    newRun.elevation = [NSKeyedArchiver archivedDataWithRootObject:self.altitude];
    
    NSMutableArray *locationArray = [NSMutableArray array];
    for (CLLocation *location in self.locations) {
        Location *locationObject = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        
        locationObject.timestamp = location.timestamp;
        locationObject.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
        locationObject.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
        [locationArray addObject:locationObject];
    }
    newRun.locations = [NSOrderedSet orderedSetWithArray:locationArray];
    self.run = newRun;
    
    // Save the context.
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)updateLabels{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timeLabel.text = [NSString stringWithFormat:@"%@",  [MathController stringifySecondCount:self.seconds usingLongFormat:NO]];
        self.distLabel.text = [NSString stringWithFormat:@"%@", [MathController stringifyDistance:self.distance]];
        self.paceLabel.text = [NSString stringWithFormat:@"%@",  [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
        self.calories.text = [NSString stringWithFormat:@"%@", [MathController stringifyCaloriesFromDist:self.distance]];
    });
}

-(void)timerCount{
    
    self.miliseconds+=10;
    
    self.milisecLabel.text = [NSString stringWithFormat:@"%i", self.miliseconds];
    if (self.miliseconds == 100) {
        self.miliseconds = 0;
        self.seconds++;
        self.timeLabel.text = [MathController stringifySecondCount:self.seconds usingLongFormat:NO];
    }
}

- (void)startLocationUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness;
    
    // Movement threshold for new events.
    self.locationManager.distanceFilter = 10; // meters
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.locationManager stopUpdatingLocation];
    
    // save
    if (buttonIndex == 0) {
        [self saveRun];
        [self performSegueWithIdentifier:detailSegueName sender:nil];
        
    // discard
    } else if (buttonIndex == 1) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - MK MapKit Delegate

#pragma mark - MapView Delegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 500, 500);
    [mapView setRegion:[mapView regionThatFits:region] animated:YES];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    for (CLLocation *newLocation in locations) {
        
        NSDate *eventDate = newLocation.timestamp;
        
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20) {
            
            // update distance
            if (self.locations.count > 0) {
                self.distance += [newLocation distanceFromLocation:self.locations.lastObject];
                
                CLLocationCoordinate2D coords[2];
                coords[0] = ((CLLocation *)self.locations.lastObject).coordinate;
                coords[1] = newLocation.coordinate;
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.mapView setRegion:region animated:YES];
                });
                [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coords count:2]];
            }
            
            [self.locations addObject:newLocation];
        }
    }
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay{

    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyLine = (MKPolyline *)overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        aRenderer.strokeColor = [UIColor blueColor];
        aRenderer.lineWidth = 5;
        return aRenderer;
    }
    
    return nil;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:detailSegueName]) {
        [[segue destinationViewController] setRun:self.run];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    }
}

#pragma mark - WCSession Delegate

-(void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo{
    
    if ([[userInfo objectForKey:@"key"] isEqualToString:@"heart"]) {
        [self.heartRate addObject:[userInfo objectForKey:@"heart"]];
        NSLog(@"recieved heart");
    }
    
}
-(void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext{
    
    if ([[applicationContext objectForKey:@"key"] isEqualToString:@"stop"]) {
        
        [self saveRun];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:detailSegueName sender:nil];
        });
        NSLog(@"received stop request");
    }
    if ([[applicationContext objectForKey:@"key"] isEqualToString:@"discard"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
        NSLog(@"received discard request");
    }
}

#pragma mark - TableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.splitsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"TableCellID" forIndexPath:indexPath];
    UILabel *time = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *distance = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *number = (UILabel *)[cell.contentView viewWithTag:3];
    UILabel *pace = (UILabel *)[cell.contentView viewWithTag:4];
    
    NSDictionary *dict = [self.splitsArray objectAtIndex:indexPath.row];
    time.text = [dict objectForKey:@"time"];
    distance.text = [dict objectForKey:@"distance"];
    number.text = [NSString stringWithFormat:@"Split %li", indexPath.row + 1];
    pace.text = [MathController stringifyAvgPaceFromDist:[[dict objectForKey:@"distance"] floatValue] overTime:[[dict objectForKey:@"time"] intValue]];
    return cell;
}

@end
