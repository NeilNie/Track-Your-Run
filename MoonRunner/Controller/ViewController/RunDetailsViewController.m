//
//  RunDetailsViewController.m
//  RunMaster
//
//  Created by Matt Luedke on 5/19/14.
//  Copyright (c) 2014 Matt Luedke. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "RunDetailsViewController.h"


static float const mapPadding = 1.1f;

@interface RunDetailsViewController () 

@end

@implementation RunDetailsViewController

#pragma mark - Private

-(IBAction)showAnalysis:(id)sender{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"segueShowAnalysis" sender:nil];
    });
}

- (void)loadMap
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mapView.hidden = NO;
        
        [self.mapView setRegion:[self mapRegion]];
        
        // make the line(s!) on the map
        [self.mapView addOverlays:self.colorSegmentArray];
    });
}

-(void)setUpData{
    
    self.valueA = [[NSMutableArray alloc] initWithObjects:
              [NSString stringWithFormat:@"%@'%@",
               [MathController stringifySecondCount:self.run.duration.intValue usingLongFormat:YES], self.run.miliseconds],
              [MathController stringifyAvgPaceFromDist:self.run.distance.floatValue overTime:self.run.duration.intValue],
              [MathController stringifyCaloriesFromDist:self.run.distance.floatValue],
              [RunHelper getAverageStride:self.run.stride_rate],
              [RunHelper getAverageHeartbeatFromArray:self.run.heart_rate],
              [RunHelper getMaxHeartbeatFromArray:self.run.heart_rate],
              nil];
    self.array = [NSKeyedUnarchiver unarchiveObjectWithData:self.run.splits];
    self.name = [[NSMutableArray alloc] initWithObjects:@"Stride Rate",@"Average Heart Rate", @"Max Heart Rate", nil];
    self.masterArray = [[NSMutableArray alloc] initWithObjects:self.name, self.array, nil];
}

-(void)configureView{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    self.dateLabel.text = [formatter stringFromDate:self.run.timestamp];
    self.distanceLabel.text = [MathController stringifyDistance:self.run.distance.floatValue];
}

-(void)modifyRunData:(int)feedback{
    
    self.run.feedback = [NSNumber numberWithInt:feedback];

    NSError *error = nil;
    // Save the object to persistent store
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
}

#pragma mark - Public

- (void)setRun:(Run *)newDetailRun
{
    if (_run != newDetailRun && newDetailRun.locations.count > 0) {

        _run = newDetailRun;
        self.colorSegmentArray = [MathController colorSegmentsForLocations:newDetailRun.locations.array];
    }else{
        _run = newDetailRun;
    }
}

#pragma mark - UITableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                return 80;
                break;
            case 1:
                return 83;
                break;
            case 2:
                return 125;
                break;
            default:
                return 55;
                break;
        }
    }else{
        return 65;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    switch (section) {
        case 0:
            return 6;
            break;
        case 1:
            return [self.array count];
            break;
            
        default:
            break;
    }
    return self.array.count;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (section == 1) {
        return @"Splits";
    }else{
        return nil;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            SummaryTableViewCell *cell = (SummaryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"idCellSummary" forIndexPath:indexPath];
            cell.time.text = [self.valueA objectAtIndex:0];
            cell.pace.text = [self.valueA objectAtIndex:1];
            cell.pace.text = [self.valueA objectAtIndex:3];
            return cell;
        }else if (indexPath.row == 1){
            WeatherTableViewCell *cell = (WeatherTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"idWeatherCell" forIndexPath:indexPath];
            NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:self.run.weather];
            cell.tempLabel.text = [dic objectForKey:@"temperature"];
            cell.windLabel.text = [NSString stringWithFormat:@"%@ m/h", [dic objectForKey:@"wind"]];
            cell.humidityLabel.text = [NSString stringWithFormat:@"%@%%", [dic objectForKey:@"humidity"]];
            return cell;
            
        }else if (indexPath.row == 2){
            ButtonTableCell *cell = (ButtonTableCell *)[tableView dequeueReusableCellWithIdentifier:@"idCellButton" forIndexPath:indexPath];
            return cell;
        }else{
            BasicTableViewCell *cell = (BasicTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"idCell" forIndexPath:indexPath];
            cell.subtitle.text = [self.valueA objectAtIndex:indexPath.row];
            cell.title.text = [self.name objectAtIndex:indexPath.row - 3];
            return cell;
        }
    }else{
        NSArray *tableArray = [self.masterArray objectAtIndex:indexPath.section];
        NSDictionary *dict = [tableArray objectAtIndex:indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellinfo" forIndexPath:indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"%@'%@", [dict objectForKey:@"time"], [dict objectForKey:@"mili"]];
        cell.detailTextLabel.text = [dict objectForKey:@"distance"];
        return cell;
    }
}

#pragma mark - MKMapViewDelegate

- (MKCoordinateRegion)mapRegion{
    
    MKCoordinateRegion region;
    Location *initialLoc = self.run.locations.firstObject;
    
    float minLat = initialLoc.latitude.floatValue;
    float minLng = initialLoc.longitude.floatValue;
    float maxLat = initialLoc.latitude.floatValue;
    float maxLng = initialLoc.longitude.floatValue;
    
    for (Location *location in self.run.locations) {
        if (location.latitude.floatValue < minLat) {
            minLat = location.latitude.floatValue;
        }
        if (location.longitude.floatValue < minLng) {
            minLng = location.longitude.floatValue;
        }
        if (location.latitude.floatValue > maxLat) {
            maxLat = location.latitude.floatValue;
        }
        if (location.longitude.floatValue > maxLng) {
            maxLng = location.longitude.floatValue;
        }
    }
    
    region.center.latitude = (minLat + maxLat) / 2.0f;
    region.center.longitude = (minLng + maxLng) / 2.0f;
    
    region.span.latitudeDelta = (maxLat - minLat) * mapPadding;
    region.span.longitudeDelta = (maxLng - minLng) * mapPadding;
    
    return region;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay{
    
    MulticolorPolylineSegment *polyLine = (MulticolorPolylineSegment *)overlay;
    MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
    aRenderer.strokeColor = polyLine.color;
    aRenderer.lineWidth = 5;
    return aRenderer;
}

#pragma mark - Private

-(NSDictionary *)queryWeatherAPI{
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
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
    return nil;
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

-(void)updateWeatherData{
    NSDictionary *dic = [self queryWeatherAPI];
    if (dic) {
        self.run.weather = [NSKeyedArchiver archivedDataWithRootObject:dic];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Can query weather data" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    NSError *error;
    [self.managedObjectContext save:&error];
}


#pragma mark - Lifecycle

-(void)viewDidAppear:(BOOL)animated{
    if (self.saveNewRun)
        [self.navigationItem setHidesBackButton:YES animated:YES];
    else{
        [self.navigationItem setHidesBackButton:NO animated:YES];
        self.backButton.hidden = YES;
    }
    [super viewDidAppear:YES];
}

- (void)viewDidLoad{
    
    [self configureView];
    [self loadMap];
    [self updateWeatherData];
    [self setUpData];
    [self.table reloadData];
    [super viewDidLoad];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue destinationViewController] isKindOfClass:[AnalysisViewController class]]) {
        AnalysisViewController *controller = (AnalysisViewController *)[segue destinationViewController];
        controller.run = self.run;
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    }
}

@end
