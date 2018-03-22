//
//  TransactionDetailViewController.h
//  Electrum
//
//  Created by Jasf on 22.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TransactionDetailHandlerProtocol <NSObject>
- (NSString *)transactionID:(id)object;
- (NSString *)status:(id)object;
- (NSString *)date:(id)object;
- (NSInteger)amount:(id)object;
- (NSString *)formattedAmount:(id)object;
- (NSString *)baseUnit:(id)object;
@end

@interface TransactionDetailViewController : UITableViewController
@property (strong, nonatomic) id<TransactionDetailHandlerProtocol> handler;
@end
