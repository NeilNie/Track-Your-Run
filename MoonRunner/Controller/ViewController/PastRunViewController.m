//
//  PastRunsViewController.m
//  
//
//  Created by Yongyang Nie on 3/7/16.
//
//

#import "PastRunViewController.h"
#import "AppDelegate.h"

@interface PastRunViewController ()

@end

@implementation PastRunViewController

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.runArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RunCell *cell = (RunCell *)[tableView dequeueReusableCellWithIdentifier:@"RunCell"];
    Run *runObject = [self.runArray objectAtIndex:indexPath.row];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    cell.date.text = [formatter stringFromDate:runObject.timestamp];
    cell.distance.text = [MathController stringifyDistance:runObject.distance.floatValue];
    cell.pace.text = [MathController stringifyAvgPaceFromDist:runObject.distance.floatValue overTime:runObject.duration.intValue];
    cell.time.text = [MathController stringifySecondCount:runObject.duration.intValue usingLongFormat:NO];
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObjectContext *context = [self managedObjectContext];
        NSManagedObject *eventToDelete = [context objectWithID:[[self.runArray objectAtIndex:indexPath.row] objectID]];
        
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            // Delete object from database
            [context deleteObject:eventToDelete];
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            }
            
            // Remove device from table view
            [self.runArray removeObjectAtIndex:indexPath.row];
            [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

#pragma mark - Navigation

-(IBAction)showMenu:(id)sender{
    [kMainViewController showLeftViewAnimated:YES completionHandler:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue destinationViewController] isKindOfClass:[RunDetailsViewController class]]) {
        NSIndexPath *indexPath = [self.table indexPathForSelectedRow];
        Run *run = [self.runArray objectAtIndex:indexPath.row];
        [(RunDetailsViewController *)[segue destinationViewController] setRun:run];
        NSLog(@"run %@", run);
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {

    [super viewDidLoad];
}
@end
