//
//  PasswordDialogImpl.h
//  Electrum
//
//  Created by Jasf on 24.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "PasswordDialog.h"
#import "ScreensManager.h"

@protocol PasswordDialogHandlerProtocol <NSObject>
- (void)passwordDialogDone:(NSString *)password;
@end

@interface PasswordDialogImpl : NSObject <PasswordDialog>
@property (strong, nonatomic) id<PasswordDialogHandlerProtocol> handler;
- (id)initWithScreensManager:(id<ScreensManager>)screensManager;
@end
