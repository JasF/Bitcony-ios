//
//  Managers.h
//  Electrum
//
//  Created by Jasf on 19.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextFieldDialog.h"
#import "FeedbackManager.h"
#import "PasswordDialog.h"
#import "ScreensManager.h"
#import "WaitingDialog.h"
#import "PythonBridge.h"
#import "AlertManager.h"
#import "YesNoDialog.h"

@interface Managers : NSObject
+ (instancetype)shared;
- (id<ScreensManager>)screensManager;
- (id<AlertManager>)alertManager;
- (id<WaitingDialog>)createWaitingDialog;
- (id<PasswordDialog>)createPasswordDialog;
- (id<YesNoDialog>)createYesNoDialog;
- (id<TextFieldDialog>)createTextFieldDialog;
- (id<FeedbackManager>)feedbackManager;
- (id<PythonBridge>)pythonBridge;
- (NSString *)documentsDirectory;
@end
