//
//  EnterWalletPasswordViewController.m
//  Electrum
//
//  Created by Jasf on 20.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "EnterWalletPasswordViewController.h"
#import "TextFieldCell.h"
#import "ButtonCell.h"
#import "LabelCell.h"

typedef NS_ENUM(NSInteger, Rows) {
    DescriptionRow,
    PasswordRow,
    PasswordValueRow,
    RepeatPasswordRow,
    RepeatPasswordValueRow,
    SpaceRow,
    ContinueRow,
    RowsCount
};

static CGFloat const kSpaceRowHeight = 22.f;

@interface EnterWalletPasswordViewController ()
@end

@implementation EnterWalletPasswordViewController {
    TextFieldCell *_passwordCell;
}

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    [super viewDidLoad];
    
    self.view.backgroundColor = self.navigationController.view.backgroundColor;
    [self.tableView registerNib:[UINib nibWithNibName:@"ButtonCell" bundle:nil] forCellReuseIdentifier:@"ButtonCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LabelCell" bundle:nil] forCellReuseIdentifier:@"LabelCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TextFieldCell" bundle:nil] forCellReuseIdentifier:@"TextFieldCell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.f;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)continueTapped:(id)sender {
    if ([_handler respondsToSelector:@selector(continueTapped:)]) {
        [_handler continueTapped:_passwordCell.string];
    }
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *resultCell = nil;
    switch (indexPath.row) {
        case DescriptionRow: {
            LabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LabelCell"];
            NSString *text = L(@"Please enter your seed phrase in order to restore your wallet.");
            [cell setTitle:text];
            resultCell = cell;
            break;
        }
        case PasswordRow: {
            LabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LabelCell"];
            [cell setTitle:L(@"Password:")];
            resultCell = cell;
            break;
        }
        case PasswordValueRow: {
            TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldCell"];
            resultCell = cell;
#ifdef DEBUG
            [cell setString:@"1"];
#endif
            break;
        }
        case RepeatPasswordRow: {
            LabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LabelCell"];
            [cell setTitle:L(@"Confirm Password:")];
            resultCell = cell;
            break;
        }
        case RepeatPasswordValueRow: {
            TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldCell"];
            resultCell = cell;
#ifdef DEBUG
            [cell setString:@"1"];
#endif
            break;
        }
        case SpaceRow: {
            resultCell = [UITableViewCell new];
            resultCell.backgroundColor = [UIColor clearColor];
            resultCell.contentView.backgroundColor = [UIColor clearColor];
            break;
        }
        case ContinueRow: {
            ButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
            [cell setTitle:L(@"Continue")];
            @weakify(self);
            cell.tappedHandler = ^{
                @strongify(self);
                [self continueTapped:nil];
            };
            resultCell = cell;
            break;
        }
    }
    resultCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return resultCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RowsCount;
}

#pragma mark - UITableViewDelegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == SpaceRow) {
        return kSpaceRowHeight;
    }
    return UITableViewAutomaticDimension;
}

@end
