//
//  ReceiveViewController.m
//  Electrum
//
//  Created by Jasf on 22.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "ReceiveViewController.h"
#import "TextFieldCell.h"

typedef NS_ENUM(NSInteger, Rows) {
    ReceivingAddressRow,
    ReceivingAddressValueRow,
    DescriptionRow,
    DescriptionValueRow,
    RequestedAmount,
    RequestedAmountValueRow,
    RowsCount
};

static CGFloat const kRowHeight = 44.f;

@interface ReceiveViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation ReceiveViewController

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    NSCParameterAssert(_screensManager);
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"SimpleCell" bundle:nil] forCellReuseIdentifier:@"SimpleCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TextFieldCell" bundle:nil] forCellReuseIdentifier:@"TextFieldCell"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Observers
- (IBAction)menuTapped:(id)sender {
    [_screensManager showMenuViewController];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *simpleCells = @[@(ReceivingAddressRow), @(DescriptionRow), @(RequestedAmount)];
    NSArray *textFieldCells = @[@(ReceivingAddressValueRow), @(DescriptionValueRow), @(RequestedAmountValueRow)];
    UITableViewCell *cell = nil;
    TextFieldCell *textFieldCell = nil;
    if ([simpleCells containsObject:@(indexPath.row)]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleCell"];
    }
    else if ([textFieldCells containsObject:@(indexPath.row)]) {
        textFieldCell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldCell"];
        cell = textFieldCell;
    }
    
    switch (indexPath.row) {
        case ReceivingAddressRow:
            cell.textLabel.text = L(@"Receiving address");
            break;
        case ReceivingAddressValueRow: {
            NSString *address = nil;
            if ([_handler respondsToSelector:@selector(receivingAddress:)]) {
                address = [_handler receivingAddress:nil];
            }
            [textFieldCell setString:address];
            break;
        }
        case DescriptionRow:
            cell.textLabel.text = L(@"Description");
            break;
        case DescriptionValueRow:
            break;
        case RequestedAmount:
            cell.textLabel.text = L(@"Requested amount");
            break;
        case RequestedAmountValueRow:
            [textFieldCell setRightLabelText:L(@"BTC")];
            break;
    }
    
    NSCAssert(cell, @"Unknown cell %@", indexPath);
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RowsCount;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}

@end
