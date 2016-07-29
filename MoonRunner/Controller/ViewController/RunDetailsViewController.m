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
    
    valueA = [[NSMutableArray alloc] initWithObjects:
              [NSString stringWithFormat:@"%@'%@", [MathController stringifySecondCount:self.run.duration.intValue usingLongFormat:YES], self.run.miliseconds],
              [MathController stringifyAvgPaceFromDist:self.run.distance.floatValue overTime:self.run.duration.intValue],
              [MathController stringifyCaloriesFromDist:self.run.distance.floatValue],
              [RunHelper getAverageStride:self.run.stride_rate],
              [RunHelper getAverageHeartbeatFromArray:self.run.heart_rate],
              [RunHelper getMaxHeartbeatFromArray:self.run.heart_rate],
              nil];
    array = [NSKeyedUnarchiver unarchiveObjectWithData:self.run.splits];
    name = [[NSMutableArray alloc] initWithObjects:@"Stride Rate",@"Average Heart Rate", @"Max Heart Rate", nil];
    masterArray = [[NSMutableArray alloc] initWithObjects:name, array, nil];
}

-(void)configureView{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    self.dateLabel.text = [formatter stringFromDate:self.run.timestamp];
    self.distanceLabel.text = [MathController stringifyDistance:self.run.distance.floatValue];
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
            return 5;
            break;
        case 1:
            return [array count];
            break;
            
        default:
            break;
    }
    return array.count;
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
            cell.time.text = [valueA objectAtIndex:0];
            cell.pace.text = [valueA objectAtIndex:1];
            cell.pace.text = [valueA objectAtIndex:3];
            return cell;
        }else if (indexPath.row == 1){
            ButtonTableCell *cell = (ButtonTableCell *)[tableView dequeueReusableCellWithIdentifier:@"idCellButton" forIndexPath:indexPath];
            return cell;
        }else{
            BasicTableViewCell *cell = (BasicTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"idCell" forIndexPath:indexPath];
            cell.subtitle.text = [valueA objectAtIndex:indexPath.row + 1];
            cell.title.text = [name objectAtIndex:indexPath.row - 2];
            return cell;
        }
    }else{
        NSArray *tableArray = [masterArray objectAtIndex:indexPath.section];
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

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self configureView];
    [self loadMap];
    [self setUpData];
    
    [self.table reloadData];
    [super viewDidLoad];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue destinationViewController] isKindOfClass:[AnalysisViewController class]]) {
        AnalysisViewController *controller = (AnalysisViewController *)[segue destinationViewController];
        controller.run = self.run;
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        NSLog(@"completed");
    }
}


@end
