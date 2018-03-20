//
//  ScreensManager.h
//  Electrum
//
//  Created by Jasf on 19.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>

@protocol ScreensManager <NSObject>
@property (strong, nonatomic) UIWindow *window;

- (void)showCreateWalletViewController;
- (void)showEnterOrCreateWalletViewController;
- (void)createWindowIfNeeded;
- (void)loopExec;
@end
