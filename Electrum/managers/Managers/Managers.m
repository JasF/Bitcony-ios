//
//  Managers.m
//  Electrum
//
//  Created by Jasf on 19.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "Managers.h"
#import "FeedbackManagerImpl.h"
#import "TextFieldDialogImpl.h"
#import "ScreensManagerImpl.h"
#import "PasswordDialogImpl.h"
#import "DialogsManagerImpl.h"
#import "WaitingDialogImpl.h"
#import "AlertManagerImpl.h"
#import "PythonBridgeImpl.h"
#import "YesNoDialogImpl.h"

@implementation Managers

#pragma mark - Public Static Methods
+ (instancetype)shared {
    static Managers *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [Managers new];
        [shared dialogsManager];
    });
    return shared;
}

#pragma mark - Public Methods
- (id<ScreensManager>)screensManager {
    static ScreensManagerImpl *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[ScreensManagerImpl alloc] initWithAlertManager:self.alertManager
                                                  feedbackManager:self.feedbackManager
                                                     pythonBridge:self.pythonBridge];
        ((AlertManagerImpl *)self.alertManager).screensManager = shared;
    });
    return shared;
}

- (id<AlertManager>)alertManager {
    static AlertManagerImpl *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[AlertManagerImpl alloc] init];
    });
    return shared;
}

- (id<WaitingDialog>)createWaitingDialog {
    WaitingDialogImpl *dialog = [[WaitingDialogImpl alloc] initWithScreensManager:self.screensManager];
    return dialog;
}

- (id<PasswordDialog>)createPasswordDialog {
    PasswordDialogImpl *dialog = [[PasswordDialogImpl alloc] initWithScreensManager:self.screensManager];
    dialog.handler = [self.pythonBridge handlerWithProtocol:@protocol(PasswordDialogHandlerProtocol)];
    return dialog;
}

- (id<YesNoDialog>)createYesNoDialog {
    YesNoDialogImpl *dialog = [[YesNoDialogImpl alloc] initWithScreensManager:self.screensManager];
    dialog.handler = [self.pythonBridge handlerWithProtocol:@protocol(YesNoDialogHandlerProtocol)];
    return dialog;
}

- (id<TextFieldDialog>)createTextFieldDialog {
    TextFieldDialogImpl *dialog = [[TextFieldDialogImpl alloc] initWithScreensManager:self.screensManager];
    dialog.handler = [self.pythonBridge handlerWithProtocol:@protocol(TextFieldDialogHandler)];
    return dialog;
}

- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    return basePath;
}

- (id<FeedbackManager>)feedbackManager {
    static FeedbackManagerImpl *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [FeedbackManagerImpl new];
    });
    return shared;
}

- (id<PythonBridge>)pythonBridge {
    static PythonBridgeImpl *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [PythonBridgeImpl new];
    });
    return shared;
}

- (id<DialogsManager>)dialogsManager {
    static DialogsManagerImpl *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[DialogsManagerImpl alloc] initWithPythonBridge:self.pythonBridge
                                                  textFieldDialog:self.createTextFieldDialog
                                                    waitingDialog:self.createWaitingDialog
                                                   passwordDialog:self.createPasswordDialog
                                                      yesNoDialog:self.createYesNoDialog];
    });
    return shared;
}

@end
