//
//  MenuViewController.h
//  Horoscopes
//
//  Created by Jasf on 05.11.2017.
//  Copyright © 2017 Mail.Ru. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuHandlerProtocol <NSObject>
- (void)walletTapped:(id)object;
- (void)receiveTapped:(id)object;
- (void)sendTapped:(id)object;
- (void)settingsTapped:(id)object;
@end

@interface MenuViewController : UIViewController;
@property (strong, nonatomic) id<MenuHandlerProtocol> handler;
@end
