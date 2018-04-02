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
- (UIViewController *)topViewController;
- (void)showCreateWalletViewController;
- (void)showEnterOrCreateWalletViewController;
- (void)showCreateNewSeedViewController;
- (void)showHaveASeedViewController;
- (void)showConfirmSeedViewController;
- (void)showEnterWalletPasswordViewController;
- (void)showWalletViewController;
- (void)showSettingsViewController;
- (void)showTransactionDetailViewController;
- (void)showMenuViewController;
- (void)createWindowIfNeeded;
- (UIViewController *)createHistoryViewController:(id)handler;
- (UIViewController *)createReceiveViewController:(id)handler;
- (UIViewController *)createSendViewController:(id)handler;
@end
