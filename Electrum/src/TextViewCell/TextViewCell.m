//
//  TextViewCell.m
//  Electrum
//
//  Created by Jasf on 25.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "TextViewCell.h"

static CGFloat const kRoundedCornerRadius = 8.f;
static CGFloat const kHorizontalMargin = 16.f;
@interface TextViewCell ()
@end

@implementation TextViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _textView.layer.cornerRadius = kRoundedCornerRadius;
    // Initialization code
}

- (void)setTextViewText:(NSString *)text {
    _textView.text = text;
}

- (void)setEditingAllowed:(BOOL)allowed {
    _textView.editable = allowed;
}

- (void)setStyleWithTransparentBackground:(BOOL)yes {
    if (yes) {
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.textColor = [UIColor whiteColor];
    }
    else {
        self.textView.backgroundColor = [UIColor whiteColor];
        self.textView.textColor = [UIColor blackColor];
    }
}

- (void)setAttributedString:(NSAttributedString *)attributedString {
    _textView.attributedText = attributedString;
    _textView.userInteractionEnabled = NO;
}

- (CGFloat)desiredHeight:(CGFloat)width {
    CGFloat height = [_textView sizeThatFits:CGSizeMake(width - kHorizontalMargin * 2, CGFLOAT_MAX)].height;
    return height;
}

- (NSString *)enteredText {
    return _textView.text;
}

@end
