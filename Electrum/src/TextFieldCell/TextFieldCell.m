//
//  TextFieldCell.m
//  Electrum
//
//  Created by Jasf on 22.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "TextFieldCell.h"

@interface TextFieldCell ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@end

@implementation TextFieldCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Public Methods
- (void)setAttributedString:(NSAttributedString *)string {
    _textField.attributedText = string;
}

#pragma mark - Layouting
- (void)layoutSubviews {
    [super layoutSubviews];
    [_textField sizeToFit];
    _heightConstraint.constant = _textField.height;
}

@end
