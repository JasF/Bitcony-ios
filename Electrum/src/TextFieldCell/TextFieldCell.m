//
//  TextFieldCell.m
//  Electrum
//
//  Created by Jasf on 22.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "TextFieldCell.h"

@interface TextFieldCell ()
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
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

- (void)setString:(NSString *)string {
    _textField.attributedText = [[NSAttributedString alloc] initWithString:string];
}

- (NSString *)string {
    return _textField.attributedText.string;
}

- (void)setRightLabelText:(NSString *)text {
    _rightLabel.text = text;
}

@end
