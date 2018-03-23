//
//  WalletViewController.h
//  Electrum
//
//  Created by Jasf on 21.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScreensManager.h"
#import "AlertManager.h"

@class WalletViewController;

@protocol WalletHandlerProtocol <NSObject>
- (void)viewDidLoad:(WalletViewController *)viewController;
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

@interface WalletViewController : UITableViewController <WalletHandlerProtocolDelegate>
@property (strong, nonatomic) id<ScreensManager> screensManager;
@property (strong, nonatomic) id<WalletHandlerProtocol> handler;
@property (strong, nonatomic) id<AlertManager> alertManager;
@end
