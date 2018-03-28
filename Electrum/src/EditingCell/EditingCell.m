//
//  EditingCell.m
//  Electrum
//
//  Created by Jasf on 26.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "EditingCell.h"

static CGFloat const kTextFieldConstraint = 8.f;
@interface EditingCell ()
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldLeading;
@property (weak, nonatomic) IBOutlet UIView *bottomDelimeterView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textFieldTrailing;

@end

@implementation EditingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _rightLabel.text = nil;
    _textFieldTrailing.constant = 0.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setImage:(UIImage *)image
           title:(NSString *)title
     editingText:(NSString *)editingText
bottomDelimeterVisible:(BOOL)bottomDelimeterVisible; {
    [_mainImageView setImage:image];
    _label.text = title;
    _textField.text = editingText;
    _bottomDelimeterView.hidden = !bottomDelimeterVisible;
    [self setNeedsLayout];
}

- (void)setRightText:(NSString *)text {
    _rightLabel.text = text;
    _textFieldTrailing.constant = (text.length) ? -kTextFieldConstraint : 0.f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    dispatch_async(dispatch_get_main_queue(), ^{
        _textFieldLeading.constant = self.label.xOrigin + self.label.width + ((self.label.text.length) ? kTextFieldConstraint : 0.f);
    });
}

@end
