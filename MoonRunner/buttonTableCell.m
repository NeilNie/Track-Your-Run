//
//  buttonTableCell.m
//  Run
//
//  Created by Yongyang Nie on 6/16/16.
//  Copyright © 2016 Yongyang Nie. All rights reserved.
//

#import "buttonTableCell.h"

@implementation buttonTableCell

-(IBAction)great:(id)sender{
    
    if (_delegate != nil) {
        [_delegate feedbackWithButton:self.greatButton];
    }
}

-(IBAction)ok:(id)sender{
    
    if (_delegate != nil) {
        [_delegate feedbackWithButton:self.okButton];
    }
    
}
-(IBAction)terrible:(id)sender{
    
    if (_delegate != nil) {
        [_delegate feedbackWithButton:self.terribleButton];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
