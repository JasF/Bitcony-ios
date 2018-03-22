//
//  TransactionDetailViewController.h
//  Electrum
//
//  Created by Jasf on 22.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TransactionDetailHandlerProtocol <NSObject>
@end

@interface TransactionDetailViewController : UITableViewController
@property (strong, nonatomic) id<TransactionDetailHandlerProtocol> handler;
@end
