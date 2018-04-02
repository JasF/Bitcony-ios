//
//  ReceiveViewController.m
//  Electrum
//
//  Created by Jasf on 22.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "ReceiveViewController.h"
#import "ReceiveSharingObject.h"
#import "SharingManager.h"
#import "TextFieldCell.h"
#import "EditingCell.h"
#import "ButtonsCell.h"
#import "ImageCell.h"
#import "UIImage+MDQRCode.h"

typedef NS_ENUM(NSInteger, Rows) {
    QRCodeRow,
    ReceivingAddressRow,
    RequestedAmountRow,
    DescriptionRow,
    ButtonsRow,
    RowsCount
};

typedef NS_ENUM(NSInteger, Buttons) {
    CopyButton,
    ShareButton,
    NewButton,
    ButtonsCount
};

static CGFloat const kTopInset = 8.f;
static CGFloat const kRowHeight = 44.f;

@interface ReceiveViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SharingManager *sharingManager;
@end

@implementation ReceiveViewController {
    NSString *_receivingAddress;
    NSString *_amountString;
    NSString *_descriptionString;
    NSString *_encodedString;
    ImageCell *_imageCell;
    UIImage *_qrcodeImage;
    UITextField *_addressTextField;
    UITextField *_descriptionTextField;
    UITextField *_amountTextField;
    CGFloat _keyboardHeight;
    NSString *_baseUnit;
}

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    NSCParameterAssert(_screensManager);
    [Analytics logEvent:@"ReceiveScreenDidLoad"];
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"EditingCell" bundle:nil] forCellReuseIdentifier:@"EditingCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ButtonsCell" bundle:nil] forCellReuseIdentifier:@"ButtonsCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ImageCell" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    self.tableView.contentInset = UIEdgeInsetsMake(kTopInset, 0, 0, 0);
    // Do any additional setup after loading the view.
    if ([_handler respondsToSelector:@selector(receivingAddress:)]) {
        _receivingAddress = [_handler receivingAddress:nil];
    }
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = kRowHeight;
    [self updateQRCode];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateIfNeeded];
}

- (void)updateIfNeeded {
    NSString *baseUnit = nil;
    if ([_handler respondsToSelector:@selector(baseUnit:)]) {
        baseUnit = [_handler baseUnit:nil];
    }
    if (!_baseUnit) {
        _baseUnit = baseUnit;
    }
    else if (![_baseUnit isEqualToString:baseUnit]) {
        _baseUnit = baseUnit;
        [self.tableView reloadData];
    }
}

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat deltaHeight = kbSize.height;
    self.tableView.height = self.view.height - deltaHeight;
}

- (void)keyboardWillHide:(NSNotification*)notification {
    self.tableView.height = self.view.height;
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
        case QRCodeRow: {
            ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
            _imageCell = cell;
            [_imageCell setMainImage:_qrcodeImage];
            resultCell = cell;
            break;
        }
        case ReceivingAddressRow: {
            EditingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditingCell"];
            [cell setImage:[UIImage imageNamed:@"earth.png"]
                     title:nil
               editingText:_receivingAddress
    bottomDelimeterVisible:YES];
            resultCell = cell;
            _addressTextField = cell.textField;
            _addressTextField.delegate = self;
            break;
        }
        case RequestedAmountRow: {
            EditingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditingCell"];
            [cell setImage:[UIImage imageNamed:@"calc.png"]
                     title:L(@"Amount")
               editingText:nil
    bottomDelimeterVisible:YES];
            resultCell = cell;
            [cell setRightText:_baseUnit];
            _amountTextField = cell.textField;
            _amountTextField.text = _amountString;
            _amountTextField.delegate = self;
            _amountTextField.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        }
        case DescriptionRow: {
            EditingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditingCell"];
            [cell setImage:[UIImage imageNamed:@"pen.png"]
                     title:L(@"Description")
               editingText:nil
    bottomDelimeterVisible:NO];
            resultCell = cell;
            _descriptionTextField = cell.textField;
            _descriptionTextField.text = _descriptionString;
            _descriptionTextField.delegate = self;
            _descriptionTextField.keyboardType = UIKeyboardTypeDefault;
            break;
        }
        case ButtonsRow: {
            ButtonsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonsCell"];
            [cell setTitles:@[L(@"Copy"), L(@"Share"), L(@"New")]];
            resultCell = cell;
            @weakify(self);
            cell.tapped = ^(NSInteger index) {
                @strongify(self);
                [self tappedOnButtonAtIndex:index];
            };
            break;
        }
    }
    resultCell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSCAssert(resultCell, @"Unknown cell %@", indexPath);
    return resultCell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RowsCount;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - Private Methods
- (void)updateQRCode {
    NSString *stringForEncode = [self stringForEncode];
    if ([stringForEncode isEqualToString:_encodedString]) {
        return;
    }
    
    CGFloat width = self.view.width - [ImageCell sideMargin] * 2;
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        UIImage *image = [UIImage mdQRCodeForString:stringForEncode
                                               size:width
                                          fillColor:[UIColor blackColor]];
        
        if (image) {
            _encodedString = stringForEncode;
            dispatch_async(dispatch_get_main_queue(), ^{
                _qrcodeImage = image;
                [_imageCell setMainImage:image];
            });
        }
    });
}

- (NSString *)pathedAmountString {
    return [_amountString stringByReplacingOccurrencesOfString:@"," withString:@"."];
}

- (NSString *)stringForEncode {
    if (_amountString.length || _descriptionString.length) {
        NSString *amountString = [self pathedAmountString];
        NSString *result = [NSString stringWithFormat:@"bitcoin:%@", _receivingAddress];
        if (amountString.length) {
            result = [result stringByAppendingFormat:@"?amount=%@", amountString];
            if (_descriptionString.length) {
                result = [result stringByAppendingFormat:@"&message=%@", _descriptionString];
            }
        }
        else {
            result = [result stringByAppendingFormat:@"?message=%@", _descriptionString];
        }
        return result;
    }
    return _receivingAddress;
}

- (void)tappedOnButtonAtIndex:(NSInteger)index {
    switch (index) {
        case CopyButton: {
            [UIPasteboard generalPasteboard].string = [self stringForEncode];
            break;
        }
        case ShareButton: {
            ReceiveSharingObject *objectForSharing = [[ReceiveSharingObject alloc] initWithMessage:[self stringForEncode]
                                                                                             image:_qrcodeImage];
            @weakify(self);
            self.sharingManager = [[SharingManager alloc] initWithSharingObject:objectForSharing
                                                                 viewController:self
                                                                     completion:^{
                                                                         @strongify(self);
                                                                         self.sharingManager = nil;
                                                                     }];
            [_sharingManager start];
            break;
        }
        case NewButton: {
            _amountString = nil;
            _descriptionString = nil;
            [self updateQRCode];
            [self.tableView reloadData];
            break;
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([textField isEqual:_amountTextField]) {
        _amountString = updatedString;
    }
    else if ([textField isEqual:_descriptionTextField]) {
        _descriptionString = updatedString;
    }
    [self updateQRCode];
    return YES;
    
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    textField.returnKeyType = UIReturnKeyDone;
    BOOL result = (textField == _addressTextField) ? NO : YES;
    if (result) {
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:textField action:@selector(resignFirstResponder)];
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
        toolbar.items = [NSArray arrayWithObject:barButton];
        textField.inputAccessoryView = toolbar;
    }
    return result;
}


@end
