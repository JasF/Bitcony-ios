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
@property (strong, nonatomic) UIViewController *topViewController;
- (void)showCreateWalletViewController:(id)handler;
- (void)showEnterOrCreateWalletViewController:(id)handler;
- (void)showCreateNewSeedViewController:(id)handler;
- (void)showHaveASeedViewController:(id)handler;
- (void)showConfirmSeedViewController:(id)handler;
- (void)showEnterWalletPasswordViewController:(id)handler;
- (void)showMainViewController:(id)menuHandler mainHandler:(id)mainHandler;
- (void)showWalletViewController:(id)historyHandler
                  receiveHandler:(id)receiveHandler
                     sendHandler:(id)sendHandler;
- (void)showReceiveViewController:(id)handler;
- (void)showSendViewController:(id)handler;
- (void)showSettingsViewController:(id)handler;
- (void)showTransactionDetailViewController:(id)handler;
- (void)showMenuViewController;
- (void)createWindowIfNeeded;
- (UIViewController *)createHistoryViewController:(id)handler;
- (UIViewController *)createReceiveViewController:(id)handler;
- (UIViewController *)createSendViewController:(id)handler;
@end
