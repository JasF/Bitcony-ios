//
//  HistoryViewController.m
//  Electrum
//
//  Created by Jasf on 26.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "HistoryViewController.h"
#import "WalletViewController.h"
#import "TransactionCell.h"
#import "Transaction.h"

static CGFloat const kTopInset = 8.f;
static NSTimeInterval kVerifiedActionDelay = 5.f;

@interface HistoryViewController () <UITableViewDataSource, UITableViewDelegate, HistoryHandlerProtocolDelegate>
@property (strong, nonatomic) NSArray *transactions;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation HistoryViewController {
    NSString *_baseUnit;
    NSString *_dataString;
}

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    NSCParameterAssert(_screensManager);
    NSCParameterAssert(_alertManager);
    NSCParameterAssert(_pythonBridge);
    [Analytics logEvent:@"HistoryScreenDidLoad"];
    [super viewDidLoad];
    [_pythonBridge setClassHandler:self name:@"HistoryHandlerProtocolDelegate"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_handler respondsToSelector:@selector(viewDidLoad)]) {
            [_handler viewDidLoad];
        }
    });
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.f;
    self.tableView.contentInset = UIEdgeInsetsMake(kTopInset, 0.f, 0.f, 0.f);
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TransactionCell" bundle:nil] forCellReuseIdentifier:@"TransactionCell"];
    [self updateIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateIfNeeded];
}

- (void)updateIfNeeded {
    NSString *baseUnit = nil;
    if ([_handler respondsToSelector:@selector(baseUnit)]) {
        baseUnit = [_handler baseUnit];
    }
    if (!_baseUnit) {
        _baseUnit = baseUnit;
    }
    else if (![_baseUnit isEqualToString:baseUnit]) {
        _baseUnit = baseUnit;
        [self updateAndReloadData];
    }
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
    UIImage *image = [UIImage imageNamed:transaction.statusImageName];
    [cell setStatusImage:image date:transaction.dateString amount:transaction.amount balance:transaction.balance];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSCAssert(indexPath.row < _transactions.count, @"indexPath.row must be less than number of transactions in array");
    Transaction *transaction = _transactions[indexPath.row];
    self.screensManager.pushControllerCallback = ^{
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    };
    if ([_handler respondsToSelector:@selector(transactionTapped:)]) {
        [_handler transactionTapped:transaction.txHash];
    }
}

#pragma mark - Observers
- (IBAction)menuTapped:(id)sender {
    [_screensManager showMenuViewController];
}

#pragma mark - HistoryHandlerProtocolDelegate
- (void)updateAndReloadData {
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        NSString *dataString = nil;
        if ([_handler respondsToSelector:@selector(transactionsData)]) {
            dataString = [_handler transactionsData];
        }
        if (dataString && [dataString isEqualToString:_dataString]) {
            return;
        }
        _dataString = dataString;
        dataString = [dataString stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *transactionsRepresentation = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSArray *transactions = [EKMapper arrayOfObjectsFromExternalRepresentation:transactionsRepresentation
                                                                       withMapping:[Transaction objectMapping]];
        transactions = transactions.reverseObjectEnumerator.allObjects;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.transactions = transactions;
            [self.tableView reloadData];
        });
    });
}

- (void)showMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.alertManager show:message];
    });
}

- (void)showError:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.alertManager show:message];
    });
}

- (void)showWarning:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.alertManager show:message];
    });
}

- (void)onVerified {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(verifiedAction) object:nil];
        [self performSelector:@selector(verifiedAction) withObject:nil afterDelay:kVerifiedActionDelay];
    });
}

- (void)verifiedAction {
    dispatch_python(^{
        if ([_handler respondsToSelector:@selector(saveVerified)]) {
            [_handler saveVerified];
        }
    });
}

@end

