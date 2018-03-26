//
//  Transaction.m
//  Electrum
//
//  Created by Jasf on 21.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "Transaction.h"

@implementation Transaction

+(EKObjectMapping *)objectMapping
{
    return [EKObjectMapping mappingForClass:self withBlock:^(EKObjectMapping *mapping) {
        [mapping mapPropertiesFromArray:@[@"amount", @"balance", @"date", @"status"]];
        [mapping mapKeyPath:@"tx_hash" toProperty:@"txHash"];
        [mapping mapKeyPath:@"date" toProperty:@"dateString"];
    }];
    /*
     statuses:
     
     TX_ICONS = [
     "unconfirmed.png",
     "warning.png",
     "unconfirmed.png",
     "offline_tx.png",
     "clock1.png",
     "clock2.png",
     "clock3.png",
     "clock4.png",
     "clock5.png",
     "confirmed.p   ng",
     ]
     
     */
}

- (void)setAmount:(NSString *)amount {
    _amount = [amount stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
}

- (void)setBalance:(NSString *)balance {
    _balance = [balance stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
}

- (void)setDateString:(NSString *)dateString {
    _dateString = dateString;
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm'"];
    self.date = [dateFormatter dateFromString:_dateString];
}

@end
