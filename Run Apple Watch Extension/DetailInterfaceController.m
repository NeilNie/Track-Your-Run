//
//  DetailInterfaceController.m
//  Run
//
//  Created by Yongyang Nie on 2/20/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import "DetailInterfaceController.h"

@interface DetailInterfaceController ()

@end

@implementation DetailInterfaceController

- (void)willActivate {
    
    if ([WCSession isSupported]) {
        NSLog(@"Activated");
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        
        if (![session isReachable] && re == NO) {
            [self pushControllerWithName:@"notice" context:nil];
            re = YES;
        }
        
    }else{
        NSLog(@"not supported");
    }
    [self setUpView];
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

-(void)setUpView{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.Distance setText:[Math stringifyDistance:[[data objectForKey:@"distance"] floatValue]]];
        [self.Time setText:[Math stringifySecondCount:[[data objectForKey:@"time"] intValue] usingLongFormat:NO]];
        [self.Pace setText:[Math stringifyAvgPaceFromDist:[[data objectForKey:@"distance"] floatValue] overTime:[[data objectForKey:@"time"] intValue]]];
        [self.Heartrate setText:[NSString stringWithFormat:@"%@bpm", [[data objectForKey:@"max"] lastObject]]];
        [self.milisecondsLabel setText:[NSString stringWithFormat:@"%@", [data objectForKey:@"mili"]]];
    });
    
}

- (IBAction)saveagain {
    
    if ([WCSession isSupported]) {
        NSLog(@"Activated");
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        
        if ([session isReachable]) {
            
            //save data to iphone
            [[WCSession defaultSession] sendMessage:[[NSUserDefaults standardUserDefaults] objectForKey:@"localData"] replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                
            } errorHandler:^(NSError * _Nonnull error) {
                NSLog(@"error %@", error);
                
            }];
            NSLog(@"sent message %@", data);
            [self pushControllerWithName:@"home" context:nil];
            
        }else{
            NSLog(@"can't be saved");
            [self pushControllerWithName:@"home" context:nil];
        }
        
    }else{
        NSLog(@"not supported");
    }
}

- (IBAction)save {
    
    if ([WCSession isSupported]) {
        NSLog(@"Activated");
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        
        //save data to iphone
        [[WCSession defaultSession] sendMessage:data replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
            
        } errorHandler:^(NSError * _Nonnull error) {
            NSLog(@"error %@", error);
            
        }];
        NSLog(@"sent message %@", data);
        [self pushControllerWithName:@"home" context:nil];
        
    }else{
        NSLog(@"not supported");
    }
}

- (IBAction)back {
    
    
}
@end



