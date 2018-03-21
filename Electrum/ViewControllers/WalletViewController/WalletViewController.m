//
//  WalletViewController.m
//  Electrum
//
//  Created by Jasf on 21.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "WalletViewController.h"

static NSTimeInterval kActionTimeInterval = 0.8f;

@interface WalletViewController () <UITableViewDataSource, UITableViewDelegate>
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
    
    @weakify(self);
    _timer = [NSTimer scheduledTimerWithTimeInterval:kActionTimeInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
        @strongify(self);
        if ([self.handler respondsToSelector:@selector(timerAction:)]) {
            [self.handler timerAction:nil];
        }
    }];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
    cell.textLabel.text = @"Transaction history cell";
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.f;
}

#pragma mark - Observers
- (IBAction)menuTapped:(id)sender {
    [_screensManager showMenuViewController];
}

#pragma mark - WalletHandlerProtocolDelegate
- (void)updateAndReloadData {
    NSString *dataString = nil;
    if ([_handler respondsToSelector:@selector(transactionsData:)]) {
        dataString = [_handler transactionsData:nil];
    }
    dataString = [dataString stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *dictionariesArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    // easyMapper
    
    [self.tableView reloadData];
}

@end
