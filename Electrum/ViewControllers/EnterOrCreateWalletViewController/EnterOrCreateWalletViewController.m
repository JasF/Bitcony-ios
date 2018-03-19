//
//  EnterOrCreateWalletViewController.m
//  Electrum
//
//  Created by Jasf on 19.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "EnterOrCreateWalletViewController.h"
#import "ButtonCell.h"

typedef NS_ENUM(NSInteger, Rows) {
    AddWalletRow,
    RowsCount
};

@interface EnterOrCreateWalletViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation EnterOrCreateWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 50.f;
    self.tableView.estimatedRowHeight = 100.f;
    [self.tableView registerNib:[UINib nibWithNibName:@"ButtonCell" bundle:nil] forCellReuseIdentifier:@"ButtonCell"];

    // Do any additional setup after loading the view.
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
            [cell setTitle:L(@"create_cell")];
            return cell;
        }
    }
    return [UITableViewCell new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RowsCount;
}

@end
