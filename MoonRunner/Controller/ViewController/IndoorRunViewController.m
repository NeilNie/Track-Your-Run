//
//  NewRunViewController.m
//  RunMaster
//
//  Created by Matt Luedke on 5/19/14.
//  Copyright (c) 2014 Matt Luedke. All rights reserved.
//

#import "IndoorRunViewController.h"

//int it = 3;

static NSString * const detailSegueName = @"NewRunDetails";

@interface IndoorRunViewController ()

@end

@implementation IndoorRunViewController

#pragma mark - Lifecycle

-(void)viewDidLoad {
    
    //modify view
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
    
    [super viewDidLoad];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer invalidate];
}

#pragma mark - IBActions

- (IBAction)stopPressed:(id)sender
{
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
    
}

#pragma mark - Private

-(void)countDown{
    
}

- (void)saveRun{
    
    if (self.splitsArray.count > 0) {
        
    }
    
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
    });
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    // save
    if (buttonIndex == 0) {
        [self saveRun];
        [self performSegueWithIdentifier:detailSegueName sender:nil];
        
        // discard
    } else if (buttonIndex == 1) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"%@", self.run);
    if ([[segue identifier] isEqualToString:detailSegueName]) {
        [[segue destinationViewController] setRun:self.run];
    }
}

#pragma mark - TableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
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
    NSDictionary *dict = [self.splitsArray objectAtIndex:indexPath.row];
    time.text = [dict objectForKey:@"time"];
    distance.text = [dict objectForKey:@"distance"];
    return cell;
}

@end
