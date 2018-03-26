//
//  Transaction.h
//  Electrum
//
//  Created by Jasf on 21.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <Foundation/Foundation.h>

@import EasyMapping;

@interface Transaction : NSObject <EKMappingProtocol>
@property (nonatomic, strong) NSString *balance;
@property (nonatomic, strong) NSString *amount;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) NSString *dateString;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *txHash;
- (NSString *)statusImageName;
@end
