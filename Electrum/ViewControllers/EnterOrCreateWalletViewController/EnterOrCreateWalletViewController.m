//
//  EnterOrCreateWalletViewController.m
//  Electrum
//
//  Created by Jasf on 19.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "EnterOrCreateWalletViewController.h"
#import "CreateWalletCell.h"
#import <objc/runtime.h>
#import "ButtonCell.h"

typedef NS_ENUM(NSInteger, Rows) {
    AddWalletRow,
    RowsCount
};

@interface EnterOrCreateWalletViewController () <UITableViewDelegate, UITableViewDataSource>
@end

@implementation EnterOrCreateWalletViewController {
    NSArray *_walletsNames;
}

- (void)viewDidLoad {
    //NSCParameterAssert(_handler);
    [super viewDidLoad];
    [Analytics logEvent:@"EnterOrCreateWalletScreenDidLoad"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100.f;
    [self.tableView registerNib:[UINib nibWithNibName:@"ButtonCell" bundle:nil] forCellReuseIdentifier:@"ButtonCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CreateWalletCell" bundle:nil] forCellReuseIdentifier:@"CreateWalletCell"];
    self.tableView.separatorColor = [UIColor clearColor];
    NSString *locale = [NSLocale preferredLanguages].firstObject;
    NSArray *components = [locale componentsSeparatedByString:@"-"];
    if (components.count > 1) {
        locale = components[0];
    }
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUIAndReloadData];
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
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row < _walletsNames.count);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSCAssert(indexPath.row < _walletsNames.count, @"trying delete unknown cell at indexPath: %@", indexPath);
        if (indexPath.row >= _walletsNames.count) {
            return;
        }
        if ([_handler respondsToSelector:@selector(deleteWalletAtIndex:)]) {
            [_handler deleteWalletAtIndex:@(indexPath.row)];
        }
        if ([_handler respondsToSelector:@selector(walletsNames)]) {
            _walletsNames = [_handler walletsNames];
        }
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
        self.navigationItem.rightBarButtonItem = (_walletsNames.count) ? self.editButtonItem : nil;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.row < _walletsNames.count) {
        NSString *walletName = _walletsNames[indexPath.row];
        ButtonCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
        cell = buttonCell;
        [buttonCell setDelimeterVisible:(indexPath.row + 1 < _walletsNames.count)];
        @weakify(self);
        buttonCell.tappedHandler = ^{
            @strongify(self);
            [self openWalletTapped:walletName];
        };
        [buttonCell setButtonImage:[UIImage imageNamed:@"wallet"]];
        [buttonCell setTitle:walletName];
    }
    else {
        CreateWalletCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:@"CreateWalletCell"];
        cell = buttonCell;
        [buttonCell setTitle:L(@"Create Wallet")];
        @weakify(self);
        [buttonCell setButtonImage:[UIImage imageNamed:@"add"]];
        buttonCell.tappedHandler = ^{
            @strongify(self);
            [self createNewWalletTapped];
        };
    }
    if (!cell) {
        cell = [UITableViewCell new];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _walletsNames.count + 1;
}

#pragma mark - Private Methods
- (void)openWalletTapped:(NSString *)walletName {
    dispatch_python(^{
        if ([_handler respondsToSelector:@selector(openWalletTapped:)]) {
            [_handler openWalletTapped:walletName];
        }
    });
}

- (void)createNewWalletTapped {
    dispatch_python(^{
        if ([_handler respondsToSelector:@selector(createWalletTapped)]) {
            [_handler createWalletTapped];
        }
    });
}

- (void)updateUIAndReloadData {
    if ([_handler respondsToSelector:@selector(walletsNames)]) {
        _walletsNames = [_handler walletsNames];
    }
    if (_walletsNames.count) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        [self.tableView reloadData];
        return;
    }
    // AV: show button in center
}

@end
