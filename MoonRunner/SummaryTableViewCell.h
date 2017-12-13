//
//  SummaryTableViewCell.h
//  Run
//
//  Created by Yongyang Nie on 7/25/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SummaryTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *time;
@property (nonatomic, weak) IBOutlet UILabel *pace;
@property (nonatomic, weak) IBOutlet UILabel *calories;

@end
