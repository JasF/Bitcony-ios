//
//  CreateWalletCell.m
//  Electrum
//
//  Created by Jasf on 25.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "CreateWalletCell.h"

static CGFloat const kRoundedCornerRadius = 8.f;

@implementation CreateWalletCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)dealloc {
}

- (void)initialize {
    self.button.layer.cornerRadius = kRoundedCornerRadius;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat inset = self.button.titleLabel.xOrigin/2 - self.button.imageView.width/2;
    self.button.imageEdgeInsets = UIEdgeInsetsMake(0, -inset, 0, 0);
}

@end

