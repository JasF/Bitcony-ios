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

@protocol WalletHandlerProtocol;

@interface HistoryViewController : UIViewController
@property (strong, nonatomic) id<ScreensManager> screensManager;
@property (strong, nonatomic) id<WalletHandlerProtocol> handler;
@property (strong, nonatomic) id<AlertManager> alertManager;
@end

