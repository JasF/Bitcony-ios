//
//  PasswordDialogImpl.h
//  Electrum
//
//  Created by Jasf on 24.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "PasswordDialog.h"
#import "ScreensManager.h"

@protocol PasswordDialogHandler <NSObject>
- (void)done:(NSString *)password;
@end

@interface PasswordDialogImpl : NSObject <PasswordDialog>
@property (strong, nonatomic) id<PasswordDialogHandler> handler;
- (id)initWithScreensManager:(id<ScreensManager>)screensManager;
@end
