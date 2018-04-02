//
//  TransactionDetailViewController.m
//  Electrum
//
//  Created by Jasf on 22.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "TransactionDetailViewController.h"
#import "TextFieldCell.h"
#import "TwoLabelCell.h"

typedef NS_ENUM(NSInteger, Sections) {
    InformationSection,
    InputsSection,
    OutputsSection,
    TransactionIDSection,
    SectionsCount
};

typedef NS_ENUM(NSInteger, Rows) {
    //TransactionIDRow,
    //TransactionIDRowValue,
    DescriptionRow,
    StatusRow,
    DateRow,
    AmountRow,
    SizeRow,
    FeeRow,
    LockTimeRow,
    RowsCount
};

static CGFloat const kRowHeight = 44.f;
static CGFloat const kTopInset = 8.f;

@interface TransactionDetailViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (strong, nonatomic) NSArray *inputs;
@property (strong, nonatomic) NSArray *outputs;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation TransactionDetailViewController {
    NSString *_descriptionString;
    NSString *_dateString;
    NSString *_baseUnit;
}

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    [Analytics logEvent:@"TransactionDetailScreenDidLoad"];
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(kTopInset, 0, 0, 0);
    [self.tableView registerNib:[UINib nibWithNibName:@"SimpleCell" bundle:nil] forCellReuseIdentifier:@"SimpleCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TextFieldCell" bundle:nil] forCellReuseIdentifier:@"TextFieldCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TwoLabelCell" bundle:nil] forCellReuseIdentifier:@"TwoLabelCell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = kRowHeight;
    [self updateInputsOutputs];
    if ([_handler respondsToSelector:@selector(baseUnit)]) {
        _baseUnit = [_handler baseUnit];
    }
    if ([_handler respondsToSelector:@selector(descriptionString)]) {
        _descriptionString = [_handler descriptionString];
    }
    if ([_handler respondsToSelector:@selector(date)]) {
        _dateString = [_handler date];
    }
    
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
    CGFloat deltaHeight = kbSize.height + 64.f;
    self.tableView.height = self.view.height - deltaHeight;
}

- (void)keyboardWillHide:(NSNotification*)notification {
    self.tableView.height = self.view.height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == InformationSection) {
        return [self tableView:tableView informationCellForRowAtIndexPath:indexPath];
    }
    else if (indexPath.section == InputsSection || indexPath.section == OutputsSection || indexPath.section == TransactionIDSection) {
        if (!indexPath.row) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleCell"];
            NSInteger count = (indexPath.section == InputsSection) ? _inputs.count : _outputs.count;
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.text = (indexPath.section == TransactionIDSection) ? [NSString stringWithFormat:@"%@:", L(@"Transaction ID")] : [NSString stringWithFormat:@"%@ (%@):",  (indexPath.section == InputsSection) ? L(@"Inputs") : L(@"Outputs"), @(count)];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        NSInteger index = indexPath.row-1;
        NSArray *stringsArray = (indexPath.section == TransactionIDSection) ? @[[self transactionIDAttributedString]] : (indexPath.section == InputsSection) ? _inputs : _outputs;
        NSCAssert(stringsArray.count > index, @"index %@ out of bounds in %@", @(index), stringsArray);
        NSAttributedString *string = stringsArray[index];
        TextFieldCell *cell =(TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:@"TextFieldCell"];
        [cell setAttributedString:string];
        cell.textField.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    NSCAssert(false, @"Unknown section");
    return [UITableViewCell new];
}

- (NSAttributedString *)transactionIDAttributedString {
    NSString *value = nil;
    if ([_handler respondsToSelector:@selector(transactionID)]) {
        value = [_handler transactionID];
    }
    return [[NSAttributedString alloc] initWithString:(value.length) ? value : @""];
}

- (UITableViewCell *)tableView:(UITableView *)tableView informationCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *resultCell = nil;
    switch (indexPath.row) {
        case DescriptionRow: {
            TwoLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwoLabelCell"];
            [cell setLeftLabel:(_descriptionString.length) ? L(@"Description") : @"" rightLabel:_descriptionString];
            resultCell = cell;
            break;
        }
        case StatusRow: {
            TwoLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwoLabelCell"];
            NSString *value = nil;
            if ([_handler respondsToSelector:@selector(status)]) {
                value = [_handler status];
            }
            [cell setLeftLabel:[NSString stringWithFormat:@"%@:", L(@"Status")] rightLabel:SL(value)];
            resultCell = cell;
            break;
        }
        case DateRow: {
            TwoLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwoLabelCell"];
            [cell setLeftLabel:_dateString.length ? [NSString stringWithFormat:@"%@:", L(@"Date")] : @"" rightLabel:_dateString];
            resultCell = cell;
            break;
        }
        case AmountRow: {
            TwoLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwoLabelCell"];
            NSNumber *amount = 0;
            if ([_handler respondsToSelector:@selector(amount)]) {
                amount = [_handler amount];
            }
            NSString *formattedAmount = nil;
            if ([_handler respondsToSelector:@selector(formattedAmount)]) {
                formattedAmount = [_handler formattedAmount];
            }
            formattedAmount = [formattedAmount stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            NSString *text = nil;
            NSString *rightText = nil;
            if (amount.integerValue == 0) {
                text = L(@"Transaction unrelated to your wallet");
                formattedAmount = nil;
            }
            else if (amount.integerValue > 0.f) {
                text = L(@"Amount received:");
            }
            else {
                text = L(@"Amount sent:");
            }
            if (formattedAmount) {
                rightText = [NSString stringWithFormat:@"%@ %@", formattedAmount, _baseUnit];
            }
            [cell setLeftLabel:text rightLabel:rightText];
            resultCell = cell;
            break;
        }
        case SizeRow: {
            TwoLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwoLabelCell"];
            NSNumber *size = 0;
            if ([_handler respondsToSelector:@selector(size)]) {
                size = [_handler size];
            }
            [cell setLeftLabel:L(@"Size:") rightLabel:[NSString stringWithFormat:L(@"%@ bytes"), size]];
            resultCell = cell;
            break;
        }
        case FeeRow: {
            TwoLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwoLabelCell"];
            NSNumber *fee = 0;
            if ([_handler respondsToSelector:@selector(fee)]) {
                fee = [_handler fee];
            }
            NSString *formattedFee = nil;
            if ([_handler respondsToSelector:@selector(formattedFee)]) {
                formattedFee = [_handler formattedFee];
            }
            [cell setLeftLabel:[NSString stringWithFormat:@"%@:", L(@"Fee")]
                    rightLabel:[NSString stringWithFormat:@"%@ %@", (fee.integerValue == 0) ? L(@"unknown") : formattedFee, _baseUnit]];
            resultCell = cell;
            break;
        }
        case LockTimeRow: {
            TwoLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwoLabelCell"];
            NSNumber *lockTime = nil;
            if ([_handler respondsToSelector:@selector(lockTime)]) {
                lockTime = [_handler lockTime];
            }
            [cell setLeftLabel:[NSString stringWithFormat:@"%@:", L(@"LockTime")]
                    rightLabel:[NSString stringWithFormat:@"%@", lockTime]];
            resultCell = cell;
            break;
        }
        default:
            break;
    }
    NSCAssert(resultCell, @"Unknown cell row: %@", indexPath);
    if (!resultCell) {
        resultCell = [UITableViewCell new];
    }
    resultCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return resultCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SectionsCount - (([self transactionIDAttributedString].string.length) ? 0 : 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case InformationSection:
            return RowsCount;
        case InputsSection:
            return _inputs.count + 1;
        case OutputsSection:
            return _outputs.count + 1;
        case TransactionIDSection:
            return 2;
        default:
            return 0;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == InformationSection && ((indexPath.row == DescriptionRow && !_descriptionString.length) ||
                                                        (indexPath.row == DateRow && !_dateString.length))) ? 0.f : kRowHeight;
}

#pragma mark - Private Methods
- (void)updateInputsOutputs {
    NSString *inputsString = nil;
    NSString *outputsString = nil;
    if ([_handler respondsToSelector:@selector(inputsJson)]) {
        inputsString = [_handler inputsJson];
    }
    inputsString = [inputsString stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    if ([_handler respondsToSelector:@selector(outputsJson)]) {
        outputsString = [_handler outputsJson];
    }
    outputsString = [outputsString stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    
    NSArray *inputsSource = [NSJSONSerialization JSONObjectWithData:[inputsString dataUsingEncoding:NSUTF8StringEncoding]
                                                            options:0
                                                              error:nil];
    NSArray *outputsSource = [NSJSONSerialization JSONObjectWithData:[outputsString dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:0
                                                               error:nil];
    
    NSMutableArray *inputs = [NSMutableArray new];
    NSMutableArray *outputs = [NSMutableArray new];
    
    NSDictionary *colorAttributes = @{@"green":@{NSBackgroundColorAttributeName:[UIColor greenColor]}, @"yellow":@{NSBackgroundColorAttributeName:[UIColor yellowColor]}};
    
    for (NSDictionary *dictionary in inputsSource) {
        NSString *left = [dictionary[@"left"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *rightColor = dictionary[@"color"];
        NSString *right = [dictionary[@"right"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSAttributedString *leftString = [[NSAttributedString alloc] initWithString:left attributes:nil];
        NSAttributedString *rightString = [[NSAttributedString alloc] initWithString:right attributes:colorAttributes[rightColor]];
        NSMutableAttributedString *string = [NSMutableAttributedString new];
        [string appendAttributedString:leftString];
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"    "]];
        [string appendAttributedString:rightString];
        
        [inputs addObject:[string copy]];
    }
    
    for (NSDictionary *dictionary in outputsSource) {
        NSString *left = [dictionary[@"left"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *leftColor = dictionary[@"color"];
        NSString *right = [dictionary[@"right"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSAttributedString *leftString = [[NSAttributedString alloc] initWithString:left attributes:colorAttributes[leftColor]];
        NSAttributedString *rightString = [[NSAttributedString alloc] initWithString:right attributes:nil];
        NSMutableAttributedString *string = [NSMutableAttributedString new];
        [string appendAttributedString:leftString];
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"    "]];
        [string appendAttributedString:rightString];
        
        [outputs addObject:[string copy]];
    }
    
    _inputs = [inputs copy];
    _outputs = [outputs copy];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:textField action:@selector(resignFirstResponder)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];
    textField.inputAccessoryView = toolbar;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return NO;
}

@end
