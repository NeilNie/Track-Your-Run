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
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.managedObjectContext = delegate.managedObjectContext;
    [self.navigationItem setHidesBackButton:YES animated:YES];

    [self setUpData];
    [self setUpGestures];
    
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    
    self.MapWidth.constant = [[UIScreen mainScreen] bounds].size.width;
    MKCoordinateRegion mapRegion;
    mapRegion.center = self.mapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.015;
    mapRegion.span.longitudeDelta = 0.015;
    [self.mapView setRegion:mapRegion animated:YES];

    // initialize the timer
    startTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    
    [super viewDidLoad];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer invalidate];
    [timeTimer invalidate];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
}

#pragma mark - IBActions

- (IBAction)stopPressed:(id)sender
{
    [self.locationManager stopUpdatingLocation];
    [timer invalidate];
    [timeTimer invalidate];
    if ([CMPedometer isPaceAvailable]) {
        [Pedometer stopPedometerUpdates];
    }
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        //pause the run
        [self startLocationUpdates];
        [self startPedometer];
        timer = [NSTimer scheduledTimerWithTimeInterval:(2.0) target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
        timeTimer = [NSTimer scheduledTimerWithTimeInterval:(0.1) target:self selector:@selector(timerCount) userInfo:nil repeats:YES];
        
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //save the run
        [self saveRun];
        [self performSegueWithIdentifier:detailSegueName sender:nil];
        
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Discard" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.navigationController popViewControllerAnimated:YES];
        
    }]];
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}
-(IBAction)splitPressed:(id)sender{
    [self splitbutton];
}

-(void)splitbutton{
    
    NSDictionary *dict = @{@"distance": [MathController stringifyDistance:self.distance],
                           @"time": [MathController stringifySecondCount:self.seconds usingLongFormat:NO],
                           @"heart": @"N/A bmp",
                           @"mili": [NSString stringWithFormat:@"%i", self.miliseconds]};
    [self.splitsArray insertObject:dict atIndex:0];
    self.distance = 0;
    self.seconds = 0;
    [self.timeLabel setText:@"00:00"];
    [self.distLabel setText:@"0.00mi"];
    NSLog(@"splits: %@", self.splitsArray);
    
    [self.table reloadData];
    [UIView animateWithDuration:1 animations:^{
        self.MapWidth.constant = 0;
        [self.view layoutIfNeeded];
    }];
    [self.mapView removeOverlays:self.mapView.overlays];
    
    //modify view
}

#pragma mark - Private

-(NSDictionary *)queryWeatherAPI{
    
    CLLocationCoordinate2D coordinate = [self getLocation]; //select * from weather.forecast where woeid in
    YQL *yql = [[YQL alloc] init];
    NSString *queryString = [NSString stringWithFormat:@"select * from weather.forecast where woeid in (SELECT woeid FROM geo.places WHERE text=\"(%f,%f)\")", coordinate.latitude, coordinate.longitude];
    NSDictionary *results = [yql query:queryString];
    
    NSString *temperature = results[@"query"][@"results"][@"channel"][@"item"][@"condition"][@"temp"];
    NSString *humidity = results[@"query"][@"results"][@"channel"][@"atmosphere"][@"humidity"];
    NSString *wind_speed = results[@"query"][@"results"][@"channel"][@"wind"][@"speed"];
    
    NSDictionary *returnResult = @{@"temperature": temperature,
                     @"humidity": humidity,
                     @"wind": wind_speed};
    return returnResult;
}

-(void)setUpGestures{
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]  initWithTarget:self action:@selector(didSwipe:)];
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]  initWithTarget:self action:@selector(didSwipe:)];
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeRight];
}

-(void)setUpData{
    
    self.seconds = 0;
    self.distance = 0;
    self.miliseconds = 0;
    it = 3;
    
    self.locations = [NSMutableArray array];
    self.splitsArray = [NSMutableArray array];
    self.strides = [NSMutableArray array];
    self.altitude = [NSMutableArray array];
    self.heartRate = [NSMutableArray array];
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
    if ([CMPedometer isPaceAvailable]){
        [Pedometer startPedometerUpdatesFromDate:[NSDate dateWithTimeIntervalSinceNow:0] withHandler:^(CMPedometerData *pedometerData, NSError *error) {
            if (!error) {
                [self.strides addObject:[MathController stringifyStrideRateFromSteps:pedometerData.numberOfSteps.intValue overTime:self.seconds]];
            }else{
                NSLog(@"%@", error);
            }
        }];
    }
    
    [altimeter startRelativeAltitudeUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAltitudeData * _Nullable altitudeData, NSError * _Nullable error) {
        if (!error) {
            [self.altitude addObject:altitudeData.relativeAltitude];
        }else{
            NSLog(@"altitude error");
        }
    }];
}

- (void)saveRun{
    
    //create a new run object
    Run *newRun = [NSEntityDescription insertNewObjectForEntityForName:@"Run" inManagedObjectContext:self.managedObjectContext];
    
    //store date
    newRun.timestamp = [NSDate date];
    
    //store numeric values
    newRun.distance = [NSNumber numberWithFloat:self.distance];
    newRun.duration = [NSNumber numberWithInt:self.seconds];
    newRun.miliseconds = [NSNumber numberWithInt:self.miliseconds];

    //store arrays or dictionaries
    newRun.elevation = [NSKeyedArchiver archivedDataWithRootObject:self.altitude];
    newRun.splits = [NSKeyedArchiver archivedDataWithRootObject:self.splitsArray];
    newRun.stride_rate = [NSKeyedArchiver archivedDataWithRootObject:self.strides];
    newRun.heart_rate = [NSKeyedArchiver archivedDataWithRootObject:self.heartRate];
    newRun.weather = [NSKeyedArchiver archivedDataWithRootObject:[self queryWeatherAPI]];
    
    //save locations as NSOrderSet
    newRun.locations = [NSOrderedSet orderedSetWithArray:[self createLocationArray]];
    
    //save run object
    self.run = newRun;
    
    //error handling
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

-(NSMutableArray *)createLocationArray{
    
    NSMutableArray *locationArray = [NSMutableArray array];
    for (CLLocation *location in self.locations) {
        Location *locationObject = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        
        locationObject.timestamp = location.timestamp;
        locationObject.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
        locationObject.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
        [locationArray addObject:locationObject];
    }
    return locationArray;
}

- (void)updateLabels{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timeLabel.text = [NSString stringWithFormat:@"%@",  [MathController stringifySecondCount:self.seconds usingLongFormat:NO]];
        self.distLabel.text = [NSString stringWithFormat:@"%@", [MathController stringifyDistance:self.distance]];
        self.paceLabel.text = [NSString stringWithFormat:@"%@",  [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
        self.calories.text = [NSString stringWithFormat:@"%@", [MathController stringifyCaloriesFromDist:self.distance]];
    });
    
    [self sendWorkoutInfo:self.distance];
}

-(void)timerCount{
    
    self.miliseconds += 10;
    
    self.milisecLabel.text = [NSString stringWithFormat:@"%i", self.miliseconds];
    if (self.miliseconds == 100) {
        self.miliseconds = 0;
        self.seconds++;
        self.timeLabel.text = [MathController stringifySecondCount:self.seconds usingLongFormat:NO];
    }
}

-(CLLocationCoordinate2D) getLocation{
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager startUpdatingLocation];
    CLLocation *location = [self.locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    return coordinate;
}


- (void)startLocationUpdates
{
    // Create the location manager if this object does not already have one.
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

    MKPolyline *polyLine = (MKPolyline *)overlay;
    MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
    aRenderer.strokeColor = [UIColor blueColor];
    aRenderer.lineWidth = 5;
    return aRenderer;
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:detailSegueName]) {
        [[segue destinationViewController] setRun:self.run];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        [(RunDetailsViewController *)[segue destinationViewController] setSaveNewRun:YES];
    }
}

#pragma mark - WCSession Delegate

-(void)sendWorkoutInfo:(float)meters{
    
    if ([WCSession isSupported]) {
        NSLog(@"Activated");
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        
        //save data to iphone
        [[WCSession defaultSession] updateApplicationContext:@{@"distance":[NSNumber numberWithFloat:meters]} error:nil];
        NSLog(@"sent");
    }
}

-(void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo{
    
    [self splitbutton];
    NSLog(@"received split request");
    
}
-(void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext{
    
    //recieve stop & save request -- stop & save the run
    if ([[applicationContext objectForKey:@"key"] isEqualToString:@"stop"]) {
        
        self.heartRate = [applicationContext objectForKey:@"data"];
        [self saveRun];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:detailSegueName sender:nil];
        });
        NSLog(@"received stop request");
    }
    
    //recieve discard request -- discard the run
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
    NSLog(@"split %@", dict);
    time.text = [dict objectForKey:@"time"];
    distance.text = [dict objectForKey:@"distance"];
    number.text = [NSString stringWithFormat:@"Split %i", (int)indexPath.row + 1];
    pace.text = [MathController stringifyAvgPaceFromDist:[[dict objectForKey:@"distance"] floatValue] overTime:[[dict objectForKey:@"time"] intValue]];
    return cell;
}

@end
