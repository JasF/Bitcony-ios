//
//  ReceiveViewController.m
//  Electrum
//
//  Created by Jasf on 22.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "ReceiveViewController.h"
#import "TextFieldCell.h"
#import "EditingCell.h"
#import "ButtonsCell.h"
#import "ImageCell.h"

@import ZXingObjC;

typedef NS_ENUM(NSInteger, Rows) {
    QRCodeRow,
    ReceivingAddressRow,
    DescriptionRow,
    RequestedAmountRow,
    ButtonsRow,
    RowsCount
};

static CGFloat const kSpaceRowHeight = 8.f;
static CGFloat const kTopInset = 8.f;
static CGFloat const kRowHeight = 44.f;

@interface ReceiveViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ReceiveViewController {
    NSString *_receivingAddress;
    NSString *_amountString;
    NSString *_descriptionString;
    ImageCell *_imageCell;
    UIImage *_qrcodeImage;
    UITextField *_addressTextField;
    UITextField *_descriptionTextField;
    UITextField *_amountTextField;
    CGFloat _keyboardHeight;
}

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    NSCParameterAssert(_screensManager);
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
        case DescriptionRow: {
            EditingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditingCell"];
            [cell setImage:[UIImage imageNamed:@"calc.png"]
                     title:L(@"Amount")
               editingText:nil
    bottomDelimeterVisible:YES];
            resultCell = cell;
            _descriptionTextField = cell.textField;
            _descriptionTextField.text = _descriptionString;
            _descriptionTextField.delegate = self;
            _descriptionTextField.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        }
        case RequestedAmountRow: {
            EditingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditingCell"];
            [cell setImage:[UIImage imageNamed:@"pen.png"]
                     title:L(@"Description")
               editingText:nil
    bottomDelimeterVisible:NO];
            resultCell = cell;
            _amountTextField = cell.textField;
            _amountTextField.text = _amountString;
            _amountTextField.delegate = self;
            _amountTextField.keyboardType = UIKeyboardTypeDefault;
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
    CGFloat width = self.view.width - [ImageCell sideMargin] * 2;
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        NSError *error = nil;
        ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
        ZXBitMatrix* result = [writer encode:[self stringForEncode]
                                      format:kBarcodeFormatQRCode
                                       width:width
                                      height:width
                                       error:&error];
        if (result) {
            CGImageRef cgimage = [[ZXImage imageWithMatrix:result] cgimage];
            UIImage *image = [[UIImage alloc] initWithCGImage:cgimage];
            dispatch_async(dispatch_get_main_queue(), ^{
                _qrcodeImage = image;
                [_imageCell setMainImage:image];
            });
            // This CGImageRef image can be placed in a UIImage, NSImage, or written to a file.
        } else {
            NSString *errorMessage = [error localizedDescription];
            DDLogError(@"%@", errorMessage);
        }
    });
}

- (NSString *)stringForEncode {
    return _receivingAddress;
}

- (void)tappedOnButtonAtIndex:(NSInteger)index {
    
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
