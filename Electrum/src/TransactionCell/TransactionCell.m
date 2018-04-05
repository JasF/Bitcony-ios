//
//  TransactionCell.m
//  Electrum
//
//  Created by Jasf on 21.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "TransactionCell.h"
#import "TransactionCellButton.h"

static CGFloat const kBorderWidth = 1.f;

@interface TransactionCell ()
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceValueLabel;
@property (weak, nonatomic) IBOutlet TransactionCellButton *button;
@end

@implementation TransactionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _amountLabel.text = L(_amountLabel.text);
    _balanceLabel.text = L(_balanceLabel.text);
    self.selectedBackgroundView = [UIView new];
    self.selectedBackgroundView.backgroundColor = RGB(48, 127, 189);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
        
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        [self setBackgroundColor:RGB(48, 127, 189)];
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
    else {
        [self setBackgroundColor:RGB(76, 76, 76)];
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
    self.contentView.layer.borderWidth = kBorderWidth;
    self.contentView.layer.cornerRadius = kBorderWidth;
}

#pragma mark - Public Methods
- (void)setStatusImage:(UIImage *)image
                  date:(NSString *)date
                amount:(NSString *)amount
               balance:(NSString *)balance {
    _statusImageView.image = image;
    _dateLabel.text = date;
    _amountValueLabel.text = amount;
    if ([amount characterAtIndex:0] == '-') {
        _amountValueLabel.textColor = RGB(254, 107, 100);
    }
    else {
        _amountValueLabel.textColor = RGB(45, 194, 53);
    }
    _balanceValueLabel.text = balance;
}

@end
