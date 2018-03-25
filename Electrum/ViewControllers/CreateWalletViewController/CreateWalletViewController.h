//
//  CreateWalletViewController.h
//  Electrum
//
//  Created by Jasf on 19.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CreateWalletHandlerProtocol <NSObject>
- (void)createNewSeedTapped:(id)aSelf;
- (void)haveASeedTapped:(id)aSelf;
@end

@interface CreateWalletViewController : UITableViewController
@property (strong, nonatomic) id<CreateWalletHandlerProtocol> handler;
@end
