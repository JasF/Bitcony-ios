//
//  SettingsViewController.m
//  Electrum
//
//  Created by Jasf on 22.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "SettingsViewController.h"
#import "SegmentedCell.h"
#import "LabelCell.h"

typedef NS_ENUM(NSInteger, Rows) {
    BaseUnitRow,
    BaseUnitValueRow,
    SeedRow,
    ServerRow,
    RowsCount
};

static CGFloat const kRowHeight = 50.f;
static CGFloat const kTopContentInset = 8.f;

@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    NSCParameterAssert(_screensManager);
    [Analytics logEvent:@"SettingsScreenDidLoad"];
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = kRowHeight;
    [self.tableView registerNib:[UINib nibWithNibName:@"LabelCellSmall" bundle:nil] forCellReuseIdentifier:@"LabelCellSmall"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SegmentedCell" bundle:nil] forCellReuseIdentifier:@"SegmentedCell"];
    // Do any additional setup after loading the view.
    self.navigationItem.title = L(@"Settings");
    self.tableView.contentInset = UIEdgeInsetsMake(kTopContentInset, 0.f, 0.f, 0.f);
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
    UITableViewCell *resultCell = nil;
    switch (indexPath.row) {
        case BaseUnitRow: {
            LabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LabelCellSmall"];
            [cell setTitle:L(@"Base unit")];
            resultCell = cell;
            break;
        }
        case BaseUnitValueRow: {
            SegmentedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SegmentedCell"];
            NSInteger index = 0;
            if ([_handler respondsToSelector:@selector(baseUnitIndex)]) {
                index = [[_handler baseUnitIndex] integerValue];
            }
            [cell setSelectedIndex:index];
            @weakify(self);
            cell.selectedIndexChangedHandler = ^(NSInteger index) {
                @strongify(self);
                if ([self.handler respondsToSelector:@selector(setBaseUnitIndex:)]) {
                    [self.handler setBaseUnitIndex:@(index)];
                }
            };
            resultCell = cell;
            break;
        }
        case SeedRow: {
            LabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LabelCellSmall"];
            [cell setTitle:L(@"Seed")];
            return cell;
        }
        case ServerRow: {
            LabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LabelCellSmall"];
            [cell setTitle:L(@"Server")];
            return cell;
        }
    }
    
    NSCAssert(resultCell, @"unknown cell: %@", indexPath);
    if (!resultCell) {
        resultCell = [UITableViewCell new];
    }
    resultCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return resultCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RowsCount;
}

#pragma mark - UITableViewDelegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return ([@[@(SeedRow), @(ServerRow)] containsObject:@(indexPath.row)]) ? indexPath : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case SeedRow: {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            dispatch_python(^{
                if ([_handler respondsToSelector:@selector(seedTapped)]) {
                    [_handler seedTapped];
                }
            });
            break;
        }
        case ServerRow: {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            dispatch_python(^{
                if ([_handler respondsToSelector:@selector(serverTapped)]) {
                    [_handler serverTapped];
                }
            });
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
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
