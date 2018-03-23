//
//  SendViewController.h
//  Electrum
//
//  Created by Jasf on 22.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScreensManager.h"
#import "AlertManager.h"

@protocol SendHandlerProtocol <NSObject>
@end

@interface SendViewController : UITableViewController
@property (strong, nonatomic) id<SendHandlerProtocol> handler;
@property (strong, nonatomic) id<ScreensManager> screensManager;
@property (strong, nonatomic) id<AlertManager> alertManager;
@end
