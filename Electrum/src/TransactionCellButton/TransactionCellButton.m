//
//  TransactionCellButton.m
//  Electrum
//
//  Created by Jasf on 26.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "TransactionCellButton.h"

static CGFloat const kBorderWidth = 1.f;

@implementation TransactionCellButton

- (void)setNormalBackground:(BOOL)animated {
    self.layer.borderWidth = kBorderWidth;
    self.layer.cornerRadius = kBorderWidth;
    [self setBackgroundColor:RGB(76, 76, 76) animated:animated];
    self.layer.borderColor = [RGB(76, 76, 76) colorWithAlphaComponent:0.7f].CGColor;
}

- (void)setHighlightedBackground:(BOOL)animated {
    self.layer.borderWidth = kBorderWidth;
    self.layer.cornerRadius = kBorderWidth;
    [self setBackgroundColor:RGB(48, 127, 189) animated:animated];
    self.layer.borderColor = [RGB(69, 145, 210) colorWithAlphaComponent:0.7f].CGColor;
}

@end
