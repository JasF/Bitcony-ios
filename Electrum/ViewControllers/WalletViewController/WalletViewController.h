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
#import "PythonBridge.h"

@class WalletViewController;

@protocol MainWindowHandlerProtocol <NSObject>
- (NSString *)baseUnit:(id)object;
- (void)updateStatus:(id)object;
@end

@protocol MainWindowHandlerProtocolDelegate <NSObject>
- (void)updateBalance:(NSString *)balanceString
             iconName:(NSString *)iconName;
@end

@interface WalletViewController : UIViewController
@property (strong, nonatomic) id<HistoryHandlerProtocol> historyHandler;
@property (strong, nonatomic) id<ReceiveHandlerProtocol> receiveHandler;
@property (strong, nonatomic) id<SendHandlerProtocol> sendHandler;
@property (strong, nonatomic) id<MainWindowHandlerProtocol> mainHandler;
@property (strong, nonatomic) id<PythonBridge> pythonBridge;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) id<ScreensManager> screensManager;
@end
