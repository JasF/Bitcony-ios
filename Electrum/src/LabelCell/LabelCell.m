//
//  LabelCell.m
//  Electrum
//
//  Created by Jasf on 25.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "LabelCell.h"

@interface LabelCell ()
@property (strong, nonatomic) IBOutlet UILabel *label;
@end

@implementation LabelCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Public Methods
- (void)setTitle:(NSString *)title {
    _label.text = title;
}

@end
