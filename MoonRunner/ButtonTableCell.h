//
//  buttonTableCell.h
//  Run
//
//  Created by Yongyang Nie on 6/16/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonTableCell : UITableViewCell

@property (assign, nonatomic) id delegate;
@property (weak, nonatomic) IBOutlet UIButton *greatButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *terribleButton;

@end

@protocol buttonTableCellDelegate <NSObject>

-(void)feedbackWithButton:(UIButton *)button;

@end
