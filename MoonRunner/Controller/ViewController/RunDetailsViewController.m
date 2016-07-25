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
    masterArray = [[NSMutableArray alloc] initWithObjects:name, array, nil];
}

-(void)configureView{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    self.dateLabel.text = [formatter stringFromDate:self.run.timestamp];
    self.distanceLabel.text = [MathController stringifyDistance:self.run.distance.floatValue];
    
    [self.table registerNib:[UINib nibWithNibName:@"SummaryCell" bundle:nil] forCellReuseIdentifier:@"idCellSummary"];
    [self.table registerNib:[UINib nibWithNibName:@"SummaryCell" bundle:nil] forCellReuseIdentifier:@"idCellSummary"];
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
    
    SummaryTableViewCell *cell = (SummaryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TableCellID" forIndexPath:indexPath];
    
    NSArray *tableArray = [masterArray objectAtIndex:indexPath.section];
    NSDictionary *dict = [tableArray objectAtIndex:indexPath.row];

//    cell.nameLabel.text = [name objectAtIndex:indexPath.row];
//    cell.value.text = [valueA objectAtIndex:indexPath.row];
//    
//    cell.time.text = [NSString stringWithFormat:@"%@'%@", [dict objectForKey:@"time"], [dict objectForKey:@"mili"]];
//    cell.distance.text = [dict objectForKey:@"distance"];
//    cell.heart.text = [NSString stringWithFormat:@"%ibpm", [[dict objectForKey:@"heart"] intValue]];
//    cell.number.text = [NSString stringWithFormat:@"Split %li", (long)indexPath.row + 1];

    return cell;
}

#pragma mark - MKMapViewDelegate

-(void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered{
    
//    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
//    options.region = mapView.region;
//    options.scale = [UIScreen mainScreen].scale;
//    options.size = mapView.frame.size;
//    
//    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
//    [snapshotter startWithCompletionHandler:^(MKMapSnapshot * _Nullable snapshot, NSError * _Nullable error) {
//        self.mapSnapShot.image = snapshot.image;
//    }];
//    mapView.hidden = YES;
}

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
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self configureView];
    [self loadMap];
    [self setUpData];
    
    [self.table reloadData];
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
