//
//  TwoLabelCell.m
//  Electrum
//
//  Created by Jasf on 27.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "TwoLabelCell.h"

@interface TwoLabelCell ()
@property (strong, nonatomic) IBOutlet UILabel *leftLabel;
@property (strong, nonatomic) IBOutlet UILabel *rightLabel;

@end

@implementation TwoLabelCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setLeftLabel:(NSString *)leftText
          rightLabel:(NSString *)rightText {
    _leftLabel.text = leftText;
    _rightLabel.text = rightText;
}

@end
