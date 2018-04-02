//
//  HistoryViewController.h
//  Electrum
//
//  Created by Jasf on 26.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScreensManager.h"
#import "AlertManager.h"
#import "PythonBridge.h"

@protocol HistoryHandlerProtocol;


@protocol HistoryHandlerProtocol <NSObject>
- (void)viewDidLoad;
- (void)saveVerified;
- (NSString *)transactionsData;
- (void)transactionTapped:(NSString *)txHash;
- (NSString *)baseUnit;
@end

@protocol HistoryHandlerProtocolDelegate <NSObject>
- (void)updateAndReloadData;
- (void)showMessage:(NSString *)message;
- (void)showError:(NSString *)message;
- (void)showWarning:(NSString *)message;
- (void)onVerified;
@end

@interface HistoryViewController : UIViewController
@property (strong, nonatomic) id<ScreensManager> screensManager;
@property (strong, nonatomic) id<HistoryHandlerProtocol> handler;
@property (strong, nonatomic) id<AlertManager> alertManager;
@property (strong, nonatomic) id<PythonBridge> pythonBridge;
@end

