//
//  SettingsViewController.h
//  Electrum
//
//  Created by Jasf on 22.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScreensManager.h"

@protocol SettingsHandlerProtocol <NSObject>
- (NSNumber *)baseUnitIndex;
- (void)setBaseUnitIndex:(NSNumber *)index;
- (void)seedTapped;
- (void)serverTapped;
@end

@interface SettingsViewController : UITableViewController
@property (strong, nonatomic) id<SettingsHandlerProtocol> handler;
@property (strong, nonatomic) id<ScreensManager> screensManager;
@end
