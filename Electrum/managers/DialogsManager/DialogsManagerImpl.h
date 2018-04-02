//
//  DialogsManagerImpl.h
//  Electrum
//
//  Created by Jasf on 01.04.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "TextFieldDialog.h"
#import "PasswordDialog.h"
#import "DialogsManager.h"
#import "WaitingDialog.h"
#import "PythonBridge.h"
#import "YesNoDialog.h"

@interface DialogsManagerImpl : NSObject <DialogsManager>
- (id)initWithPythonBridge:(id<PythonBridge>)pythonBridge
           textFieldDialog:(id<TextFieldDialog>)textFieldDialog
             waitingDialog:(id<WaitingDialog>)waitingDialog
            passwordDialog:(id<PasswordDialog>)passwordDialog
               yesNoDialog:(id<YesNoDialog>)yesNoDialog;
@end
