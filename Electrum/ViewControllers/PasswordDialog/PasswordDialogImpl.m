//
//  PasswordDialogImpl.m
//  Electrum
//
//  Created by Jasf on 24.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "PasswordDialogImpl.h"

@implementation PasswordDialogImpl {
    id<ScreensManager> _screensManager;
}

- (id)initWithScreensManager:(id<ScreensManager>)screensManager {
    if (self = [super init]) {
        _screensManager = screensManager;
    }
    return self;
}

#pragma mark - Overriden Methods - PasswordDialog
- (void)showPasswordDialogWithMessage:(NSString *)message {
    NSCParameterAssert(_handler);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *viewController = _screensManager.topViewController;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                 message:SL(message)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.secureTextEntry = YES;
        }];
        @weakify(self);
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:L(@"OK")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  @strongify(self);
                                                                  NSString *password = [[alertController textFields][0] text];
                                                                  dispatch_python(^{
                                                                      if ([self.handler respondsToSelector:@selector(passwordDialogDone:)]) {
                                                                          [self.handler passwordDialogDone:password.length ? password : @""];
                                                                      }
                                                                  });
                                                              }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:L(@"Cancel")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  @strongify(self);
                                                                  dispatch_python(^{
                                                                      if ([self.handler respondsToSelector:@selector(passwordDialogDone:)]) {
                                                                          [self.handler passwordDialogDone:@""];
                                                                      }
                                                                  });
                                                              }];
        [alertController addAction:confirmAction];
        [alertController addAction:cancel];
        [viewController presentViewController:alertController animated:YES completion:nil];
    });
}

@end
