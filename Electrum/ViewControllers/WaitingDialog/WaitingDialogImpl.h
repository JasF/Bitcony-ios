//
//  WaitingDialogImpl.h
//  Electrum
//
//  Created by Jasf on 23.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScreensManager.h"
#import "WaitingDialog.h"

@interface WaitingDialogImpl : NSObject <WaitingDialog>
- (id)initWithScreensManager:(id<ScreensManager>)screensManager;
@end
