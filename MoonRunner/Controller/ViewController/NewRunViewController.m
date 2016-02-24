//
//  NewRunViewController.m
//  RunMaster
//
//  Created by Matt Luedke on 5/19/14.
//  Copyright (c) 2014 Matt Luedke. All rights reserved.
//

#import "NewRunViewController.h"

int it = 3;

static NSString * const detailSegueName = @"NewRunDetails";

@interface NewRunViewController () 

@end

@implementation NewRunViewController

#pragma mark - Lifecycle

-(void)viewDidLoad {
    
    //modify view
    self.MapWidth.constant = [[UIScreen mainScreen] bounds].size.width;
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    self.seconds = 0;
    self.distance = 0;
    
    self.locations = [NSMutableArray array];
    if (!self.splitsArray) {
        self.splitsArray = [[NSMutableArray alloc] init];
    }
    [self.splitsArray removeAllObjects];
    
    // initialize the timer
    startTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]  initWithTarget:self action:@selector(didSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]  initWithTarget:self action:@selector(didSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeRight];
    
    self.MapWidth.constant = [[UIScreen mainScreen] bounds].size.width;
    
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
    
    NSDictionary *dict = @{@"distance": [MathController stringifyDistance:self.distance], @"time": [MathController stringifySecondCount:self.seconds usingLongFormat:NO], @"heart": @"N/A bmp"};
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
        timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(eachSecond) userInfo:nil repeats:YES];
        self.countDownLabel.hidden = YES;
        self.timeLabel.hidden = NO;
        self.distLabel.hidden = NO;
        self.paceLabel.hidden = NO;
        self.stopButton.hidden = NO;
        self.calories.hidden = NO;
        self.mapView.hidden = NO;
        self.label1.hidden = NO;
        self.Label2.hidden = NO;
        self.Label3.hidden = NO;
        self.Label4.hidden = NO;
        self.split.hidden = NO;
    }
}

-(void)startPedometer{
    
    Pedometer = [[CMPedometer alloc] init];
    [Pedometer startPedometerUpdatesFromDate:[NSDate dateWithTimeIntervalSinceNow:0] withHandler:^(CMPedometerData *pedometerData, NSError *error) {
        if (!error) {
            NSLog(@"%i", pedometerData.numberOfSteps.intValue);
        }else{
            NSLog(@"%@", error);
        }
    }];
}

- (void)saveRun{
    
    Run *newRun = [NSEntityDescription insertNewObjectForEntityForName:@"Run" inManagedObjectContext:self.managedObjectContext];
    
    newRun.distance = [NSNumber numberWithFloat:self.distance];
    newRun.duration = [NSNumber numberWithInt:self.seconds];
    newRun.timestamp = [NSDate date];
    newRun.splits = [NSKeyedArchiver archivedDataWithRootObject:self.splitsArray];
    newRun.max_heart_rate = [NSString stringWithFormat:@"N/A bpm"];
    
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
    
    NSLog(@"new run %@", newRun);
    // Save the context.
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)eachSecond{
    
    self.seconds ++;
    [self updateLabels];
}

- (void)updateLabels{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timeLabel.text = [NSString stringWithFormat:@"%@",  [MathController stringifySecondCount:self.seconds usingLongFormat:NO]];
        self.distLabel.text = [NSString stringWithFormat:@"%@", [MathController stringifyDistance:self.distance]];
        self.paceLabel.text = [NSString stringWithFormat:@"%@",  [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
        self.calories.text = [NSString stringWithFormat:@"%@", [MathController stringifyCaloriesFromDist:self.distance]];
    });
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

                MKCoordinateRegion region =
                MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500);
                [self.mapView setRegion:region animated:YES];
                
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
