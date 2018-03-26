//
//  UIView+Utils.m
//  Electrum
//
//  Created by Jasf on 26.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "UIView+Utils.h"

@implementation UIView (Utils)
- (void)utils_addFillingSubview:(UIView *)subview {
    if (subview.superview) {
        [subview removeFromSuperview];
    }
    [self addSubview:subview];
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|[subview]|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(subview)]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|[subview]|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(subview)]];
}
@end
