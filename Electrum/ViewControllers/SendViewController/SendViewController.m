//
//  SendViewController.m
//  Electrum
//
//  Created by Jasf on 22.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "QRCodeReaderViewController.h"
#import "SendViewController.h"
#import "WaitingDialogImpl.h"
#import "TextFieldCell.h"
#import "QRCodeReader.h"
#import "TwoLabelCell.h"
#import "EditingCell.h"
#import "ButtonsCell.h"
#import "ButtonCell.h"
#import "Managers.h"
#import "FeeCell.h"

typedef NS_ENUM(NSInteger, Rows) {
    SendAddressRow,
    RequestedAmountRow,
    DescriptionRow,
    FeeRow,
    FeeSliderRow,
    ButtonsRow,
    PreviewSendRow,
    RowsCount
};

typedef NS_ENUM(NSInteger, Buttons) {
    ScanButton,
    PasteButton,
    ClearButton
};

typedef NS_ENUM(NSInteger, PreviewSendButtons) {
    EmptyButton,
    PreviewButton,
    SendButton
};

static CGFloat const kRowHeight = 44.f;
static CGFloat const kNumberOfSliderSteps = 5.f - 1.f;
static CGFloat const kTopInset = 8.f;

@interface SendViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, QRCodeReaderDelegate>
@property (strong, nonatomic) FeeCell *feeCell;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation SendViewController {
    NSString *_feeDescription;
    NSString *_sendAddress;
    NSString *_sendDescriptionString;
    NSString *_amountString;
    UITextField *_payToTextField;
    UITextField *_descriptionTextField;
    UITextField *_amountTextField;
    NSString *_baseUnit;
}

- (void)viewDidLoad {
    NSCParameterAssert(_alertManager);
    NSCParameterAssert(_handler);
    NSCParameterAssert(_screensManager);
    NSCParameterAssert(_pythonBridge);
    [super viewDidLoad];
    [Analytics logEvent:@"SendScreenDidLoad"];
    [_pythonBridge setClassHandler:self name:@"SendHandlerProtocolDelegate"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = kRowHeight;
    [self.tableView registerNib:[UINib nibWithNibName:@"EditingCell" bundle:nil] forCellReuseIdentifier:@"EditingCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TwoLabelCell" bundle:nil] forCellReuseIdentifier:@"TwoLabelCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ButtonsCell" bundle:nil] forCellReuseIdentifier:@"ButtonsCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SimpleCell" bundle:nil] forCellReuseIdentifier:@"SimpleCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TextFieldCell" bundle:nil] forCellReuseIdentifier:@"TextFieldCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TableButtonCell" bundle:nil] forCellReuseIdentifier:@"TableButtonCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FeeCell" bundle:nil] forCellReuseIdentifier:@"FeeCell"];
    self.tableView.contentInset = UIEdgeInsetsMake(kTopInset, 0, 0, 0);
#ifdef DEBUG
    _sendAddress = @"39S2Vp1vcDpDDgvRgF77YtgrQeMgRgJy3v";
    _amountString = @"0.00001";
    _sendDescriptionString = @"Hi description";
#endif
    [self updateFeeDescription];
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
        [self reloadData];
    }
}

#pragma mark - Observers
- (IBAction)menuTapped:(id)sender {
    [_screensManager showMenuViewController];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *resultCell = nil;
    switch (indexPath.row) {
        case SendAddressRow: {
            EditingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditingCell"];
            [cell setImage:[UIImage imageNamed:@"earth.png"]
                     title:L(@"Pay to")
               editingText:_sendAddress
            bottomDelimeterVisible:YES];
            resultCell = cell;
            _payToTextField = cell.textField;
            _payToTextField.text = _sendAddress;
            _payToTextField.delegate = self;
            break;
        }
        case RequestedAmountRow: {
            EditingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditingCell"];
            [cell setImage:[UIImage imageNamed:@"calc.png"]
                     title:L(@"Amount")
               editingText:_amountString
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
               editingText:_sendDescriptionString
    bottomDelimeterVisible:NO];
            resultCell = cell;
            _descriptionTextField = cell.textField;
            _descriptionTextField.text = _sendDescriptionString;
            _descriptionTextField.delegate = self;
            _descriptionTextField.keyboardType = UIKeyboardTypeDefault;
            break;
        }
        case FeeRow: {
            TwoLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwoLabelCell"];
            [cell setLeftLabel:L(@"Fee") rightLabel:_feeDescription];
            resultCell = cell;
            break;
        }
        case FeeSliderRow: {
            return self.feeCell;
        }
        case ButtonsRow: {
            ButtonsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonsCell"];
            [cell setTitles:@[[UIImage imageNamed:@"photo.png"], L(@"Paste"), L(@"Clear"), L(@"Preview")]];
            resultCell = cell;
            @weakify(self);
            cell.tapped = ^(NSInteger index) {
                @strongify(self);
                [self tappedOnButtonAtIndex:index];
            };
            break;
        }
        case PreviewSendRow: {
            ButtonsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonsCell"];
            [cell setTitles:@[@"", L(@"Preview"), L(@"Send")]];
            resultCell = cell;
            @weakify(self);
            cell.tapped = ^(NSInteger index) {
                @strongify(self);
                [self tappedOnPreviewSendButtonAtIndex:index];
            };
            break;
        }
    }
    
    NSCAssert(resultCell, @"Undefined cell not allowed");
    if (!resultCell) {
        resultCell = [UITableViewCell new];
    }
    resultCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return resultCell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == FeeRow) {
        return kRowHeight;
    }
    return UITableViewAutomaticDimension;
}

- (void)tappedOnButtonAtIndex:(NSInteger)index {
    switch (index) {
        case ScanButton: {
            [self scanAction];
            break;
        }
        case PasteButton: {
            NSString *string = [UIPasteboard generalPasteboard].string;
#ifdef DEBUG
            string = @"1PsagHwPWGdCGvZ9rDDnRUhrxC3jZJkBj7";
#endif
            [self handleString:string];
            break;
        }
        case ClearButton: {
            _sendAddress = nil;
            _sendDescriptionString = nil;
            _amountString = nil;
            [self reloadData];
            break;
        }
    }
}

- (void)tappedOnPreviewSendButtonAtIndex:(NSInteger)index {
    switch (index) {
        case PreviewButton: {
            dispatch_python(^{
                if ([_handler respondsToSelector:@selector(previewTapped:)]) {
                    [_handler previewTapped:nil];
                }
            });
            break;
        }
        case SendButton: {
            dispatch_python(^{
                if ([_handler respondsToSelector:@selector(sendTapped:)]) {
                    [_handler sendTapped:nil];
                }
            });
            break;
        }
    }
}

#pragma mark - Private Methods
- (FeeCell *)feeCell {
    if (!_feeCell) {
        _feeCell =(FeeCell *)[self.tableView dequeueReusableCellWithIdentifier:@"FeeCell"];
        UISlider *slider = _feeCell.slider;
        slider.value = 0.f;
        [self updateFeeDescription];
        slider.continuous = YES;
        [slider addTarget:self
                   action:@selector(sliderValueChanged:)
         forControlEvents:UIControlEventValueChanged];
        
        [slider addTarget:self
                   action:@selector(sliderModifyFinished:)
         forControlEvents:UIControlEventTouchUpInside];
        
        [slider addTarget:self
                   action:@selector(sliderModifyFinished:)
         forControlEvents:UIControlEventTouchUpOutside];
    }
    return _feeCell;
}

- (void)reloadData {
    [self.tableView reloadData];
}

#pragma mark - Observers
- (NSInteger)sliderFilledSteps {
    UISlider *slider = self.feeCell.slider;
    CGFloat stepLength = 1.f/kNumberOfSliderSteps;
    NSInteger filledSteps = slider.value/stepLength;
    if (slider.value - (filledSteps * stepLength) > stepLength/2) {
        filledSteps++;
    }
    return filledSteps;
}

- (void)sliderValueChanged:(UISlider *)slider {
    [self updateFeeDescription];
}

#pragma mark - Private Methods
- (void)setAmountString:(NSString *)string {
    _amountString = [string stringByReplacingOccurrencesOfString:@"," withString:@"."];
}

- (void)sliderModifyFinished:(UISlider *)slider {
    NSInteger filledSteps = [self sliderFilledSteps];
    CGFloat stepLength = 1.f/kNumberOfSliderSteps;
    [slider setValue:stepLength * filledSteps animated:NO];
    [self updateFeeDescription];
}

- (void)updateFeeDescription {
    CGFloat value = [self sliderFilledSteps];
    NSDictionary *blocksDictionary = @{@(0):@(25), @(1):@(10), @(2):@(5), @(3):@(2)};
    NSDictionary *satDictionary = @{@(0):@(1), @(1):@(2), @(2):@(2), @(3):@(5), @(4):@(7)};
    NSNumber *numberOfBlocks = blocksDictionary[@(value)];
    NSString *firstLine = (numberOfBlocks) ? [NSString stringWithFormat:L(@"Within %@ blocks"), numberOfBlocks] : L(@"In the next block");
    NSString *secondLine = [NSString stringWithFormat:@"%@ sat/byte", satDictionary[@(value)]];
    NSString *newLine = [NSString stringWithFormat:@"%@, %@", firstLine, secondLine];
    if (![newLine isEqualToString:_feeDescription]) {
        if ([_handler respondsToSelector:@selector(feePosChanged:)]) {
            [_handler feePosChanged:@(value)];
        }
        _feeDescription = newLine;
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:FeeRow inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

- (void)scanAction {
    if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
        static QRCodeReaderViewController *vc = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
            vc                   = [QRCodeReaderViewController readerWithCancelButtonTitle:L(@"Cancel")
                                                                                codeReader:reader
                                                                       startScanningAtLoad:YES
                                                                    showSwitchCameraButton:YES
                                                                           showTorchButton:YES];
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
        });
        vc.delegate = self;
        [vc setCompletionWithBlock:^(NSString *resultAsString) {
            [self handleString:resultAsString];
        }];
        
        [self presentViewController:vc animated:YES completion:NULL];
    }
}

- (void)handleString:(NSString *)string {
    if (!string.length) {
        return;
    }
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:string];
    _sendAddress = components.path;
    if ([components.scheme isEqualToString:@"bitcoin"]) {
        for (NSURLQueryItem *item in components.queryItems) {
            if ([item.name isEqualToString:@"amount"]) {
                _amountString = item.value;
            }
            else if ([item.name isEqualToString:@"message"]) {
                _sendDescriptionString = item.value;
            }
        }
    }
    [self reloadData];
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
    if ([textField isEqual:_payToTextField]) {
        _sendAddress = updatedString;
    }
    else if ([textField isEqual:_descriptionTextField]) {
        _sendDescriptionString = updatedString;
    }
    else if ([textField isEqual:_amountTextField]) {
        _amountString = updatedString;
    }
    return YES;
}

#pragma mark - SendHandlerProtocolDelegate
- (NSString *)payToText {
    return _sendAddress;
}

- (NSString *)descriptionText {
    return _sendDescriptionString;
}

- (NSString *)amountText {
    return [_amountString stringByReplacingOccurrencesOfString:@"," withString:@"."];
}

- (void)requestInputFieldsTexts {
    if ([_handler respondsToSelector:@selector(inputFieldsTexts:)]) {
        [_handler inputFieldsTexts:@[self.payToText?:@"", self.descriptionText?:@"", self.amountText?:@""]];
    }
}

#pragma mark - QRCodeReaderDelegate
- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    [reader stopScanning];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
