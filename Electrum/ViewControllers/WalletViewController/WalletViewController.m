//
//  WalletViewController.m
//  Electrum
//
//  Created by Jasf on 21.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "WalletViewController.h"
#import "TransactionCell.h"
#import "Transaction.h"

static NSTimeInterval kActionTimeInterval = 0.8f;

@interface WalletViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSArray *transactions;
@end

@implementation WalletViewController {
    NSTimer *_timer;
}

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    NSCParameterAssert(_screensManager);
    [super viewDidLoad];
    if ([_handler respondsToSelector:@selector(viewDidLoad:)]) {
        [_handler viewDidLoad:self];
    }
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.f;
    
    @weakify(self);
    _timer = [NSTimer scheduledTimerWithTimeInterval:kActionTimeInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
        @strongify(self);
        if ([self.handler respondsToSelector:@selector(timerAction:)]) {
            [self.handler timerAction:nil];
        }
    }];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TransactionCell" bundle:nil] forCellReuseIdentifier:@"TransactionCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _transactions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSCAssert(indexPath.row < _transactions.count, @"indexPath.row must be less than number of transactions in array");
    Transaction *transaction = _transactions[indexPath.row];
    TransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TransactionCell"];
    [cell setStatusImage:nil date:transaction.dateString amount:transaction.amount balance:transaction.balance];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSCAssert(indexPath.row < _transactions.count, @"indexPath.row must be less than number of transactions in array");
    Transaction *transaction = _transactions[indexPath.row];
    if ([_handler respondsToSelector:@selector(transactionTapped:)]) {
        [_handler transactionTapped:transaction.txHash];
    }
}

#pragma mark - Observers
- (IBAction)menuTapped:(id)sender {
    [_screensManager showMenuViewController];
}

#pragma mark - WalletHandlerProtocolDelegate
- (void)updateAndReloadData {
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        NSString *dataString = nil;
        if ([_handler respondsToSelector:@selector(transactionsData:)]) {
            dataString = [_handler transactionsData:nil];
        }
        dataString = [dataString stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *transactionsRepresentation = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSArray *transactions = [EKMapper arrayOfObjectsFromExternalRepresentation:transactionsRepresentation
                                                                       withMapping:[Transaction objectMapping]];
        transactions = [transactions sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.transactions = transactions;
            [self.tableView reloadData];
        });
    });
}

@end
