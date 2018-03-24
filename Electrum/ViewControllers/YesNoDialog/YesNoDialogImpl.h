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

@protocol YesNoDialogHandler <NSObject>
- (void)done:(NSNumber *)result;
@end

@interface YesNoDialogImpl : NSObject <YesNoDialog>
@property (strong, nonatomic) id<YesNoDialogHandler> handler;
- (id)initWithScreensManager:(id<ScreensManager>)screensManager;
@end
