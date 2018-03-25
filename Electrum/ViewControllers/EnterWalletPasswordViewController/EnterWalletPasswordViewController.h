//
//  EnterWalletPasswordViewController.h
//  Electrum
//
//  Created by Jasf on 20.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EnterWalletPasswordHandlerProtocol <NSObject>
- (void)continueTapped:(NSString *)password;
@end

@interface EnterWalletPasswordViewController : UITableViewController
@property (strong, nonatomic) id<EnterWalletPasswordHandlerProtocol> handler;
@end
