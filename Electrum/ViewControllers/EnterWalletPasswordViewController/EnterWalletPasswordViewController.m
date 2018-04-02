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

@interface EnterWalletPasswordViewController () <UITextFieldDelegate>
@end

@implementation EnterWalletPasswordViewController {
    UITextField *_passwordTextField;
    UITextField *_repeatPasswordTextField;
    NSString *_password;
    NSString *_repeatPassword;
    ButtonCell *_continueCell;
}

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    [Analytics logEvent:@"EnterWalletPasswordScreenDidLoad"];
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
    NSString *text = _passwordTextField.text;
    dispatch_python(^{
        if ([_handler respondsToSelector:@selector(continueTapped:)]) {
            [_handler continueTapped:text];
        }
    });
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
            _passwordTextField = cell.textField;
            cell.textField.delegate = self;
            resultCell = cell;
#ifdef DEBUG
            [cell setString:@"1"];
            _password = cell.string;
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
            _repeatPasswordTextField = cell.textField;
            cell.textField.delegate = self;
            resultCell = cell;
#ifdef DEBUG
            [cell setString:@"1"];
            _repeatPassword = cell.string;
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
            _continueCell = cell;
            [cell setButtonEnabled:[self passwordsEquals]];
            [cell setTitle:L(@"Continue")];
            [cell setDelimeterVisible:NO];
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

#pragma mark - Private Methods
- (BOOL)passwordsEquals {
    return ((!_password.length && !_repeatPassword.length) || [_password isEqualToString:_repeatPassword]);
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:textField action:@selector(resignFirstResponder)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];
    textField.inputAccessoryView = toolbar;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([textField isEqual:_passwordTextField]) {
        _password = updatedString;
    }
    else if ([textField isEqual:_repeatPasswordTextField]) {
        _repeatPassword = updatedString;
    }
    [_continueCell setButtonEnabled:[self passwordsEquals]];
    return YES;
}

@end
