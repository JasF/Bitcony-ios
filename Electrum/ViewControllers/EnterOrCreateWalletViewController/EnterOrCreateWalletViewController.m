//
//  EnterOrCreateWalletViewController.m
//  Electrum
//
//  Created by Jasf on 19.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "EnterOrCreateWalletViewController.h"
#import "ButtonCell.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSInteger, Rows) {
    AddWalletRow,
    RowsCount
};

@interface EnterOrCreateWalletViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation EnterOrCreateWalletViewController

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    [super viewDidLoad];
    self.tableView.rowHeight = 50.f;
    self.tableView.estimatedRowHeight = 100.f;
    [self.tableView registerNib:[UINib nibWithNibName:@"ButtonCell" bundle:nil] forCellReuseIdentifier:@"ButtonCell"];

    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
#ifdef AUTO_FORWARD
    [self createNewWalletTapped];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case AddWalletRow: {
            ButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
            @weakify(self);
            cell.tappedHandler = ^{
                @strongify(self);
                [self createNewWalletTapped];
            };
            [cell setTitle:L(@"create_cell")];
            return cell;
        }
    }
    return [UITableViewCell new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RowsCount;
}

#pragma mark - Private Methods
- (void)createNewWalletTapped {
    if ([_handler respondsToSelector:@selector(createWalletTapped:)]) {
        [_handler createWalletTapped:_handler];
    }
}

@end
