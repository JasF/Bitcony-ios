//
//  TransactionCell.h
//  Electrum
//
//  Created by Jasf on 21.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionCell : UITableViewCell
@property (copy, nonatomic) dispatch_block_t tapped;
- (void)setStatusImage:(UIImage *)image
                  date:(NSString *)date
                amount:(NSString *)amount
               balance:(NSString *)balance;
@end
