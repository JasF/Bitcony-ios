//
//  YesNoDialogImpl.m
//  Electrum
//
//  Created by Jasf on 24.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "YesNoDialogImpl.h"

@implementation YesNoDialogImpl {
    id<ScreensManager> _screensManager;
}

- (id)initWithScreensManager:(id<ScreensManager>)screensManager {
    NSCParameterAssert(screensManager);
    if (self = [super init]) {
        _screensManager = screensManager;
    }
    return self;
}

#pragma mark - YesNoDialog
- (void)showYesNoDialogWithMessage:(NSString *)message {
    NSCParameterAssert(_handler);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *viewController = _screensManager.topViewController;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                 message:SL(message)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        @weakify(self);
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:L(@"Yes")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  @strongify(self);
                                                                  dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
                                                                      if ([self.handler respondsToSelector:@selector(yesNoDialogDone:)]) {
                                                                          [self.handler yesNoDialogDone:@(YES)];
                                                                      }
                                                                  });
                                                              }];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:L(@"No")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  @strongify(self);
                                                                  dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
                                                                      if ([self.handler respondsToSelector:@selector(yesNoDialogDone:)]) {
                                                                          [self.handler yesNoDialogDone:@(NO)];
                                                                      }
                                                                  });
                                                              }];
        [alertController addAction:yesAction];
        [alertController addAction:noAction];
        [viewController presentViewController:alertController animated:YES completion:nil];
    });
}

@end
