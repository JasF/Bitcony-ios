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
- (void)showTextFieldDialogWithMessage:(NSString *)message
                           placeholder:(NSString *)placeholder
                         serverAddress:(NSNumber *)serverAddress {
    NSCParameterAssert(_handler);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *addressComponent = @"";
        NSInteger portComponent = 0;
        if (serverAddress) {
            NSArray *components = [placeholder componentsSeparatedByString:@":"];
            if (components.count >= 2) {
                addressComponent = components[0];
                NSString *portNumber = components[1];
                NSNumberFormatter *f = [NSNumberFormatter new];
                f.numberStyle = NSNumberFormatterDecimalStyle;
                portComponent = [f numberFromString:portNumber].integerValue;
            }
        }
        UIViewController *viewController = _screensManager.topViewController;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                 message:SL(message)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = placeholder;
            if (serverAddress.boolValue) {
                textField.placeholder = L(@"address");
                textField.text = addressComponent;
                textField.keyboardType = UIKeyboardTypeASCIICapable;
            }
        }];
        if (serverAddress.boolValue) {
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = L(@"port");
                if (portComponent) {
                    textField.text = [@(portComponent) stringValue];
                }
                textField.keyboardType = UIKeyboardTypeNumberPad;
            }];
        }
        @weakify(self);
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:L(@"OK")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  @strongify(self);
                                                                  NSString *text = [[alertController textFields][0] text];
                                                                  if (serverAddress.boolValue) {
                                                                      NSString *portString = [[alertController textFields][1] text];
                                                                      NSNumberFormatter *f = [NSNumberFormatter new];
                                                                      f.numberStyle = NSNumberFormatterDecimalStyle;
                                                                      NSInteger portNumber = [f numberFromString:portString].integerValue;
                                                                      if ((text.length && portNumber) ||
                                                                          (!text.length && !portNumber)) {
                                                                          dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
                                                                              if ([self.handler respondsToSelector:@selector(done:)]) {
                                                                                  [self.handler doneWithServerAddress:@[text, @(portNumber)]];
                                                                              }
                                                                          });
                                                                      }
                                                                      return;
                                                                  }
                                                                  dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
                                                                      if ([self.handler respondsToSelector:@selector(done:)]) {
                                                                          [self.handler done:text];
                                                                      }
                                                                  });
                                                              }];
        
        [alertController addAction:confirmAction];
        [viewController presentViewController:alertController animated:YES completion:nil];
    });
}
@end
