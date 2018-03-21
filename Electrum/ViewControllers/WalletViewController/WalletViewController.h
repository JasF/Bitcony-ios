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
@end

@interface WalletViewController : UITableViewController
@property (strong, nonatomic) id<ScreensManager> screensManager;
@property (strong, nonatomic) id<WalletHandlerProtocol> handler;
@end
