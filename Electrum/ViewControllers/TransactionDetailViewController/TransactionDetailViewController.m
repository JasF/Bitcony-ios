//
//  TransactionDetailViewController.m
//  Electrum
//
//  Created by Jasf on 22.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "TransactionDetailViewController.h"

typedef NS_ENUM(NSInteger, Rows) {
    TransactionIDRow,
    TransactionIDRowValue,
    StatusRow,
    DateRow,
    AmountRow,
    SizeRow,
    FeeRow,
    RowsCount
};

static CGFloat const kRowHeight = 44.f;

@interface TransactionDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation TransactionDetailViewController

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"SimpleCell" bundle:nil] forCellReuseIdentifier:@"SimpleCell"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleCell"];
    switch (indexPath.row) {
        case TransactionIDRow:
            cell.textLabel.text = L(@"Transaction ID:");
            break;
        case TransactionIDRowValue: {
            NSString *value = nil;
            if ([_handler respondsToSelector:@selector(transactionID:)]) {
                value = [_handler transactionID:nil];
            }
            cell.textLabel.text = value.length ? value : L(@"Unknown");
            break;
        }
        case StatusRow: {
            NSString *value = nil;
            if ([_handler respondsToSelector:@selector(status:)]) {
                value = [_handler status:nil];
            }
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", L(@"Status:"), value];
            break;
        }
        case DateRow: {
            NSString *value = nil;
            if ([_handler respondsToSelector:@selector(date:)]) {
                value = [_handler date:nil];
            }
            cell.textLabel.text = [NSString stringWithFormat:L(@"Date: %@"), value];
            break;
        }
        case AmountRow: {
            NSNumber *amount = 0;
            if ([_handler respondsToSelector:@selector(amount:)]) {
                amount = [_handler amount:nil];
            }
            NSString *formattedAmount = nil;
            if ([_handler respondsToSelector:@selector(formattedAmount:)]) {
                formattedAmount = [_handler formattedAmount:nil];
            }
            formattedAmount = [formattedAmount stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            NSString *baseUnit = nil;
            if ([_handler respondsToSelector:@selector(baseUnit:)]) {
                baseUnit = [_handler baseUnit:nil];
            }
            
            NSString *text = nil;
            if (amount.integerValue == 0) {
                text = L(@"Transaction unrelated to your wallet");
            }
            else if (amount.integerValue > 0.f) {
                text = [NSString stringWithFormat:@"%@ %@ %@", L(@"Amount received:"), formattedAmount, baseUnit];
            }
            else {
                text = [NSString stringWithFormat:@"%@ %@ %@", L(@"Amount sent:"), formattedAmount, baseUnit];
            }
            cell.textLabel.text = text;
            break;
        }
        case SizeRow: {
            NSNumber *size = 0;
            if ([_handler respondsToSelector:@selector(size:)]) {
                size = [_handler size:nil];
            }
            cell.textLabel.text = [NSString stringWithFormat:L(@"%@ %@ bytes"), L(@"Size:"), size];
            break;
        }
        case FeeRow: {
            NSNumber *fee = 0;
            if ([_handler respondsToSelector:@selector(fee:)]) {
                fee = [_handler fee:nil];
            }
            NSString *formattedFee = nil;
            if ([_handler respondsToSelector:@selector(formattedFee:)]) {
                formattedFee = [_handler formattedFee:nil];
            }
            NSString *text = [NSString stringWithFormat:@"%@: %@", L(@"Fee"), (fee.integerValue == 0) ? L(@"unknown") : formattedFee];
            cell.textLabel.text = text;
            break;
        }
        default:
            break;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RowsCount;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
