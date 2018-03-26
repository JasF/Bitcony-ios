//
//  WalletViewController.h
//  Electrum
//
//  Created by Jasf on 21.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryViewController.h"
#import "ScreensManager.h"
#import "AlertManager.h"
#import "ReceiveViewController.h"
#import "SendViewController.h"

@class WalletViewController;

@protocol WalletHandlerProtocol <NSObject>
- (void)viewDidLoad:(UIViewController *)viewController;
- (void)timerAction:(id)object;
- (NSString *)transactionsData:(id)object;
- (void)transactionTapped:(NSString *)txHash;
@end

@protocol WalletHandlerProtocolDelegate <NSObject>
- (void)updateAndReloadData;
- (void)showMessage:(NSString *)message;
- (void)showError:(NSString *)message;
- (void)showWarning:(NSString *)message;
@end

@interface WalletViewController : UIViewController
@property (strong, nonatomic) id<WalletHandlerProtocol> historyHandler;
@property (strong, nonatomic) id<ReceiveHandlerProtocol> receiveHandler;
@property (strong, nonatomic) id<SendHandlerProtocol> sendHandler;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) id<ScreensManager> screensManager;
@end
