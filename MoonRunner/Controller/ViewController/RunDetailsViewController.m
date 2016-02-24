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

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self configureView];
    [self loadMap];
    name = [[NSMutableArray alloc] initWithObjects:@"Time", @"Average pace", @"Calories", @"Stride rate", @"Average heartbeat", @"Max heartbeat", nil];
    valueA = [[NSMutableArray alloc] initWithObjects:
              [MathController stringifySecondCount:self.run.duration.intValue usingLongFormat:YES],
              [MathController stringifyAvgPaceFromDist:self.run.distance.floatValue overTime:self.run.duration.intValue],
              [MathController stringifyCaloriesFromDist:self.run.distance.floatValue],
              @"N/A",
              @"N/A",
              [NSString stringWithFormat:@"%d", self.run.max_heart_rate.intValue],
              nil];
    array = [NSKeyedUnarchiver unarchiveObjectWithData:self.run.splits];
    masterArray = [[NSMutableArray alloc] initWithObjects:name, array, nil];
    [self.table reloadData];
    NSLog(@"data %@ %@", name, valueA);
}

-(void)configureView{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    self.dateLabel.text = [formatter stringFromDate:self.run.timestamp];
    self.distanceLabel.text = [MathController stringifyDistance:self.run.distance.floatValue];
}

#pragma mark - Private

- (void)loadMap
{
    NSLog(@"loaded map");
    self.mapView.hidden = NO;
    
    // set the map bounds
    [self.mapView setRegion:[self mapRegion]];
    
    // make the line(s!) on the map
    [self.mapView addOverlays:self.colorSegmentArray];
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
        return 55;
    }else{
        return 70;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    switch (section) {
        case 0:
            return [name count];
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
    
    SplitCell *cell = (SplitCell *)[tableView dequeueReusableCellWithIdentifier:@"TableCellID" forIndexPath:indexPath];
    
    NSArray *tableArray = [masterArray objectAtIndex:indexPath.section];
    NSDictionary *dict = [tableArray objectAtIndex:indexPath.row];

    switch (indexPath.section) {
        case 0:
            
            cell.nameLabel.hidden = NO;
            cell.value.hidden = NO;
            cell.time.hidden = YES;
            cell.distance.hidden = YES;
            cell.heart.hidden = YES;
            cell.number.hidden = YES;
            
            cell.nameLabel.text = [name objectAtIndex:indexPath.row];
            cell.value.text = [valueA objectAtIndex:indexPath.row];
            break;
        case 1:
            
            cell.nameLabel.hidden = YES;
            cell.value.hidden = YES;
            cell.time.hidden = NO;
            cell.distance.hidden = NO;
            cell.heart.hidden = NO;
            cell.number.hidden = NO;
            
            cell.time.text = [dict objectForKey:@"time"];
            cell.distance.text = [dict objectForKey:@"distance"];
            cell.heart.text = [NSString stringWithFormat:@"%ibpm", [[dict objectForKey:@"heart"] intValue]];
            cell.number.text = [NSString stringWithFormat:@"Split %li", (long)indexPath.row + 1];
            break;
            
        default:
            break;
    }
    
    return cell;
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
    
    if ([overlay isKindOfClass:[MulticolorPolylineSegment class]]) {
        MulticolorPolylineSegment *polyLine = (MulticolorPolylineSegment *)overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        aRenderer.strokeColor = polyLine.color;
        aRenderer.lineWidth = 5;
        return aRenderer;
    }
    
    return nil;
}

@end
