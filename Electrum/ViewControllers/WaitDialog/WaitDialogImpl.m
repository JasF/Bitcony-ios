//
//  WaitDialogImpl.m
//  Electrum
//
//  Created by Jasf on 23.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "WaitDialogImpl.h"

@import JGProgressHUD;

@interface WaitDialogImpl () <WailDialog>
@end

@implementation WaitDialogImpl {
    JGProgressHUD *_hud;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

#pragma mark - overriden methods - WailDialog
- (void)showInView:(UIView *)view withMessage:(NSString *)message {
    _hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    _hud.textLabel.text = message;
    _hud.indicatorView = [[JGProgressHUDIndeterminateIndicatorView alloc] init];
    [_hud showInView:view];
}

- (void)close {
    [_hud dismissAnimated:YES];
}

@end
