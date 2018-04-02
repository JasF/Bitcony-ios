//
//  TransactionDetailViewController.h
//  Electrum
//
//  Created by Jasf on 22.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TransactionDetailHandlerProtocol <NSObject>
- (NSString *)transactionID;
- (NSString *)descriptionString;
- (NSString *)status;
- (NSString *)date;
- (NSNumber *)amount;
- (NSString *)formattedAmount;
- (NSString *)baseUnit;
- (NSNumber *)size;
- (NSNumber *)fee;
- (NSString *)formattedFee;
- (NSString *)inputsJson;
- (NSString *)outputsJson;
- (NSNumber *)lockTime;
@end

@interface TransactionDetailViewController : UIViewController
@property (strong, nonatomic) id<TransactionDetailHandlerProtocol> handler;
@end
