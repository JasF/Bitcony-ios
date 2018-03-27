//
//  SendViewController.m
//  Electrum
//
//  Created by Jasf on 22.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "SendViewController.h"
#import "WaitingDialogImpl.h"
#import "TextFieldCell.h"
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
    PhotoButton,
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

@interface SendViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
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
}

- (void)viewDidLoad {
    NSCParameterAssert(_alertManager);
    NSCParameterAssert(_handler);
    NSCParameterAssert(_screensManager);
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = kRowHeight;
    [self.tableView registerNib:[UINib nibWithNibName:@"EditingCell" bundle:nil] forCellReuseIdentifier:@"EditingCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TwoLabelCell" bundle:nil] forCellReuseIdentifier:@"TwoLabelCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ButtonsCell" bundle:nil] forCellReuseIdentifier:@"ButtonsCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SimpleCell" bundle:nil] forCellReuseIdentifier:@"SimpleCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TextFieldCell" bundle:nil] forCellReuseIdentifier:@"TextFieldCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TableButtonCell" bundle:nil] forCellReuseIdentifier:@"TableButtonCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FeeCell" bundle:nil] forCellReuseIdentifier:@"FeeCell"];
    if ([_handler respondsToSelector:@selector(viewDidLoad:)]) {
        [_handler viewDidLoad:self];
    }
    self.tableView.contentInset = UIEdgeInsetsMake(kTopInset, 0, 0, 0);
#ifdef DEBUG
    _sendAddress = @"39S2Vp1vcDpDDgvRgF77YtgrQeMgRgJy3v";
    _amountString = @"0.00001";
    _sendDescriptionString = @"Hi description";
#endif
    [self updateFeeDescription];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    NSArray *simpleCells = @[@(PayToRow), @(DescriptionRow), @(FeeDescriptionRow), @(AmountRow), @(FeeRow)];
    NSArray *textFieldCells = @[@(PayToValueRow), @(DescriptionValueRow), @(AmountValueRow)];
    NSArray *buttonCells = @[@(ClearRow), @(PreviewRow), @(SendRow)];
    
    UITableViewCell *cell = nil;
    TextFieldCell *textFieldCell = nil;
    ButtonCell *buttonCell = nil;
    
    if ([simpleCells containsObject:@(indexPath.row)]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleCell"];
    }
    else if ([textFieldCells containsObject:@(indexPath.row)]) {
        textFieldCell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldCell"];
        [textFieldCell setRightLabelText:nil];
        cell = textFieldCell;
        textFieldCell.textField.delegate = self;
    }
    else if ([buttonCells containsObject:@(indexPath.row)]) {
        buttonCell = [tableView dequeueReusableCellWithIdentifier:@"TableButtonCell"];
        cell = buttonCell;
    }
    */
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
            /*
        case PayToRow: {
            cell.textLabel.text = L(@"Pay to");
            break;
        }
        case PayToValueRow: {
            _payToTextField = textFieldCell.textField;
            _payToTextField.text = _sendAddress;
            break;
        }
        case DescriptionRow: {
            cell.textLabel.text = L(@"Description");
            break;
        }
        case DescriptionValueRow: {
            _descriptionTextField = textFieldCell.textField;
            _descriptionTextField.text = _sendDescriptionString;
            break;
        }
        case AmountRow: {
            cell.textLabel.text = L(@"Amount");
            break;
        }
        case AmountValueRow: {
            _amountTextField = textFieldCell.textField;
            [textFieldCell setRightLabelText:L(@"BTC")];
            _amountTextField.text = _amountString;
            break;
        }
        case ClearRow: {
            cell.textLabel.text = L(@"Clear");
            break;
        }
        case PreviewRow: {
            cell.textLabel.text = L(@"Preview");
            break;
        }
        case SendRow: {
            cell.textLabel.text = L(@"Send");
            break;
        }
             */
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

#pragma mark - UITextFieldDelegate
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
    return _amountString;
}

@end
