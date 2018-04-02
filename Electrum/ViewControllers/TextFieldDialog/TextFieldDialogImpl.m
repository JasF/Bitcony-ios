//
//  TextFieldDialogImpl.m
//  Electrum
//
//  Created by Jasf on 25.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "TextFieldDialogImpl.h"

@implementation TextFieldDialogImpl {
    id<ScreensManager> _screensManager;
}

#pragma mark - Initialization
- (id)initWithScreensManager:(id<ScreensManager>)screensManager {
    NSCParameterAssert(screensManager);
    if (self = [super init]) {
        _screensManager = screensManager;
    }
    return self;
}

#pragma mark - TextFieldDialog
- (void)showTextFieldDialogWithMessage:(NSString *)message placeholder:(NSString *)placeholder {
    NSCParameterAssert(_handler);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *viewController = _screensManager.topViewController;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                 message:SL(message)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = placeholder;
        }];
        @weakify(self);
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:L(@"OK")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  @strongify(self);
                                                                  NSString *text = [[alertController textFields][0] text];
                                                                  dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
                                                                      if ([self.handler respondsToSelector:@selector(done:)]) {
                                                                          [self.handler done:text];
                                                                      }
                                                                  });
                                                              }];
        
        
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:L(@"Cancel")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             @strongify(self);
                                                             dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
                                                                 if ([self.handler respondsToSelector:@selector(done:)]) {
                                                                     [self.handler done:nil];
                                                                 }
                                                             });
                                                         }];
        
        [alertController addAction:confirmAction];
        [viewController presentViewController:alertController animated:YES completion:nil];
    });
}
@end
