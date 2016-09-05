//
//  PlanCollectionViewCell.h
//  Run
//
//  Created by Yongyang Nie on 8/12/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlanCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) NSDate *date;

@property (weak, nonatomic) IBOutlet UIImageView *weather;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
