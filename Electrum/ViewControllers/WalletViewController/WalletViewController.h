//
//  WalletViewController.h
//  Electrum
//
//  Created by Jasf on 21.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScreensManager.h"

@class WalletViewController;

@protocol WalletHandlerProtocol <NSObject>
- (void)viewDidLoad:(WalletViewController *)viewController;
- (void)timerAction:(id)object;
- (NSString *)transactionsData:(id)object;
- (void)transactionTapped:(NSString *)txHash;
@end

@protocol WalletHandlerProtocolDelegate <NSObject>
- (void)updateAndReloadData;
@end

@interface WalletViewController : UITableViewController <WalletHandlerProtocolDelegate>
@property (strong, nonatomic) id<ScreensManager> screensManager;
@property (strong, nonatomic) id<WalletHandlerProtocol> handler;
@end
