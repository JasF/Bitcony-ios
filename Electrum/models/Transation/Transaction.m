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
}

- (void)setAmount:(NSString *)amount {
    _amount = [amount stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
}

- (void)setBalance:(NSString *)balance {
    _balance = [balance stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
}

- (void)setDateString:(NSString *)dateString {
    _dateString = SL(dateString);
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm'"];
    self.date = [dateFormatter dateFromString:_dateString];
    if (!self.date) {
        self.date = [NSDate date];
    }
}

- (NSString *)statusImageName {
    NSDictionary *names = @{@(0):@"unconfirmed.png", @(1):@"warning.png", @(2):@"unconfirmed.png", @(3):@"offline_tx.png", @(4):@"clock.png", @(5):@"clock.png", @(6):@"clock.png", @(7):@"clock.png", @(8):@"clock.png", @(9):@"confirmed.png"};
    NSString *imageName = names[@(self.status)];
    NSCAssert(imageName, @"Unknown status: %@", @(_status));
    return imageName;
}

@end
