//
//  YesNoDialogImpl.h
//  Electrum
//
//  Created by Jasf on 24.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YesNoDialog.h"
#import "ScreensManager.h"

@protocol YesNoDialogHandlerProtocol <NSObject>
- (void)yesNoDialogDone:(NSNumber *)result;
@end

@interface YesNoDialogImpl : NSObject <YesNoDialog>
@property (strong, nonatomic) id<YesNoDialogHandlerProtocol> handler;
- (id)initWithScreensManager:(id<ScreensManager>)screensManager;
@end
