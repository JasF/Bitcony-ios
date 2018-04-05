//
//  DialogsManagerImpl.m
//  Electrum
//
//  Created by Jasf on 01.04.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "DialogsManagerImpl.h"
#import "TextFieldDialog.h"
#import "PasswordDialog.h"

@interface DialogsManagerImpl () <TextFieldDialog, WaitingDialog, PasswordDialog, YesNoDialog>
@end

@implementation DialogsManagerImpl {
    id<PythonBridge> _pythonBridge;
    id<TextFieldDialog> _textFieldDialog;
    id<WaitingDialog> _waitingDialog;
    id<PasswordDialog> _passwordDialog;
    id<YesNoDialog> _yesNoDialog;
}

- (id)initWithPythonBridge:(id<PythonBridge>)pythonBridge
           textFieldDialog:(id<TextFieldDialog>)textFieldDialog
             waitingDialog:(id<WaitingDialog>)waitingDialog
            passwordDialog:(id<PasswordDialog>)passwordDialog
               yesNoDialog:(id<YesNoDialog>)yesNoDialog {
    NSCParameterAssert(pythonBridge);
    NSCParameterAssert(textFieldDialog);
    NSCParameterAssert(waitingDialog);
    NSCParameterAssert(passwordDialog);
    NSCParameterAssert(yesNoDialog);
    if (self = [self init]) {
        _pythonBridge = pythonBridge;
        _textFieldDialog = textFieldDialog;
        _waitingDialog = waitingDialog;
        _passwordDialog = passwordDialog;
        _yesNoDialog = yesNoDialog;
        [_pythonBridge setClassHandler:self name:@"TextFieldDialog"];
        [_pythonBridge setClassHandler:self name:@"WaitingDialog"];
        [_pythonBridge setClassHandler:self name:@"PasswordDialog"];
        [_pythonBridge setClassHandler:self name:@"YesNoDialog"];
    }
    return self;
}

#pragma mark - TextFieldDialog
- (void)showTextFieldDialogWithMessage:(NSString *)message
                           placeholder:(NSString *)placeholder
                         serverAddress:(NSNumber *)serverAddress {
    [_textFieldDialog showTextFieldDialogWithMessage:message
                                         placeholder:placeholder
                                       serverAddress:serverAddress];
}

#pragma mark - WaitingDialog
- (void)showWaitingDialogWithMessage:(NSString *)message {
    [_waitingDialog showWaitingDialogWithMessage:message];
}

- (void)waitingDialogClose {
    [_waitingDialog waitingDialogClose];
}

#pragma mark - PasswordDialog
- (void)showPasswordDialogWithMessage:(NSString *)message {
    [_passwordDialog showPasswordDialogWithMessage:message];
}

- (void)showYesNoDialogWithMessage:(NSString *)message {
    [_yesNoDialog showYesNoDialogWithMessage:message];
}

@end
