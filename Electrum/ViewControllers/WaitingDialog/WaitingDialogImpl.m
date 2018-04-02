//
//  WaitingDialogImpl.m
//  Electrum
//
//  Created by Jasf on 23.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "WaitingDialogImpl.h"

@import JGProgressHUD;

@interface WaitingDialogImpl () <WaitingDialog>
@end

@implementation WaitingDialogImpl {
    JGProgressHUD *_hud;
    id<ScreensManager> _screensManager;
}

- (id)initWithScreensManager:(id<ScreensManager>)screensManager {
    if (self = [super init]) {
        NSCParameterAssert(screensManager);
        _screensManager = screensManager;
    }
    return self;
}

#pragma mark - overriden methods - WaitingDialog
- (void)showWaitingDialogWithMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self waitingDialogClose];
        _hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        _hud.textLabel.text = SL(message);
        _hud.indicatorView = [[JGProgressHUDIndeterminateIndicatorView alloc] init];
        [_hud showInView:_screensManager.topViewController.view];
    });
}

- (void)waitingDialogClose {
    dispatch_block_t block = ^{
        [_hud dismissAnimated:YES];
        _hud = nil;
    };
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

@end
