//
//  UIViewController+Electrum.m
//  Electrum
//
//  Created by Jasf on 26.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "UIViewController+Electrum.h"
#import <objc/runtime.h>

static const char kIndex;
@implementation UIViewController (Electrum)
- (NSInteger)index {
    NSNumber *index = objc_getAssociatedObject(self, &kIndex);
    return index.integerValue;
}

- (void)setIndex:(NSInteger)index {
    objc_setAssociatedObject(self, &kIndex, @(index), OBJC_ASSOCIATION_RETAIN);
}
@end
