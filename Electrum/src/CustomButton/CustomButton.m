//
//  CustomButton.m
//  Electrum
//
//  Created by Jasf on 25.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "CustomButton.h"

static CGFloat const kAnimationDuration = 0.2f;
@implementation CustomButton

#pragma mark - Initialization
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

- (id)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [self setNormalBackground:NO];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.4f] forState:UIControlStateDisabled];
    self.adjustsImageWhenHighlighted = NO;
    
    
    [self addTarget:self action:@selector(touchBegin:) forControlEvents:UIControlEventTouchDragEnter];
    [self addTarget:self action:@selector(touchBegin:) forControlEvents:UIControlEventTouchDown];
    
    [self addTarget:self action:@selector(touchFinished:) forControlEvents:UIControlEventTouchDragExit];
    [self addTarget:self action:@selector(touchFinished:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(touchFinished:) forControlEvents:UIControlEventTouchUpOutside];
    [self addTarget:self action:@selector(touchFinished:) forControlEvents:UIControlEventTouchCancel];
}

- (void)touchFinished:(id)sender {
    [self setNormalBackground:YES];
}

- (void)touchBegin:(id)sender {
    [self setHighlightedBackground:YES];
}

#pragma mark - Private Methods
- (void)setNormalBackground:(BOOL)animated {
    [self setBackgroundColor:RGB(140, 191, 222) animated:animated];
}

- (void)setHighlightedBackground:(BOOL)animated {
    [self setBackgroundColor:RGB(71, 99, 112) animated:animated];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor animated:(BOOL)animated {
    dispatch_block_t block = ^{
        [super setBackgroundColor:backgroundColor];
    };
    if (animated) {
        [UIView animateWithDuration:kAnimationDuration animations:block];
    }
    else {
        block();
    }
}

@end
