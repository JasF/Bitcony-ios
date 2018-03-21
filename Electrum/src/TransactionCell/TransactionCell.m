//
//  TransactionCell.m
//  Electrum
//
//  Created by Jasf on 21.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "TransactionCell.h"

@interface TransactionCell ()
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceValueLabel;
@end

@implementation TransactionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _amountLabel.text = L(_amountLabel.text);
    _balanceLabel.text = L(_balanceLabel.text);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Public Methods
- (void)setStatusImage:(UIImage *)image
                  date:(NSString *)date
                amount:(NSString *)amount
               balance:(NSString *)balance {
    _statusImageView.image = image;
    _dateLabel.text = date;
    _amountValueLabel.text = amount;
    _balanceValueLabel.text = balance;
}

@end
