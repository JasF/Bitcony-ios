//
//  TransactionDetailViewController.m
//  Electrum
//
//  Created by Jasf on 22.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "TransactionDetailViewController.h"
#import "TextFieldCell.h"

typedef NS_ENUM(NSInteger, Sections) {
    InformationSection,
    InputsSection,
    OutputsSection,
    SectionsCount
};

typedef NS_ENUM(NSInteger, Rows) {
    TransactionIDRow,
    TransactionIDRowValue,
    StatusRow,
    DateRow,
    AmountRow,
    SizeRow,
    FeeRow,
    RowsCount
};

static CGFloat const kRowHeight = 44.f;

@interface TransactionDetailViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSArray *inputs;
@property (strong, nonatomic) NSArray *outputs;
@end

@implementation TransactionDetailViewController

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"SimpleCell" bundle:nil] forCellReuseIdentifier:@"SimpleCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TextFieldCell" bundle:nil] forCellReuseIdentifier:@"TextFieldCell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = kRowHeight;
    [self updateInputsOutputs];
    // Do any additional setup after loading the view.
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
    else if (indexPath.section == InputsSection || indexPath.section == OutputsSection) {
        if (!indexPath.row) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleCell"];
            NSInteger count = (indexPath.section == InputsSection) ? _inputs.count : _outputs.count;
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", (indexPath.section == InputsSection) ? L(@"Inputs") : L(@"Outputs"), @(count)];
            return cell;
        }
        NSInteger index = indexPath.row-1;
        NSArray *stringsArray = (indexPath.section == InputsSection) ? _inputs : _outputs;
        NSCAssert(stringsArray.count > index, @"index %@ out of bounds in %@", @(index), stringsArray);
        NSAttributedString *string = stringsArray[index];
        TextFieldCell *cell =(TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:@"TextFieldCell"];
        [cell setAttributedString:string];
        return cell;
    }
    NSCAssert(false, @"Unknown section");
    return [UITableViewCell new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView informationCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleCell"];
    switch (indexPath.row) {
        case TransactionIDRow:
            cell.textLabel.text = L(@"Transaction ID:");
            break;
        case TransactionIDRowValue: {
            NSString *value = nil;
            if ([_handler respondsToSelector:@selector(transactionID:)]) {
                value = [_handler transactionID:nil];
            }
            cell.textLabel.text = value.length ? value : L(@"Unknown");
            break;
        }
        case StatusRow: {
            NSString *value = nil;
            if ([_handler respondsToSelector:@selector(status:)]) {
                value = [_handler status:nil];
            }
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", L(@"Status:"), value];
            break;
        }
        case DateRow: {
            NSString *value = nil;
            if ([_handler respondsToSelector:@selector(date:)]) {
                value = [_handler date:nil];
            }
            cell.textLabel.text = [NSString stringWithFormat:L(@"Date: %@"), value];
            break;
        }
        case AmountRow: {
            NSNumber *amount = 0;
            if ([_handler respondsToSelector:@selector(amount:)]) {
                amount = [_handler amount:nil];
            }
            NSString *formattedAmount = nil;
            if ([_handler respondsToSelector:@selector(formattedAmount:)]) {
                formattedAmount = [_handler formattedAmount:nil];
            }
            formattedAmount = [formattedAmount stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            NSString *baseUnit = nil;
            if ([_handler respondsToSelector:@selector(baseUnit:)]) {
                baseUnit = [_handler baseUnit:nil];
            }
            
            NSString *text = nil;
            if (amount.integerValue == 0) {
                text = L(@"Transaction unrelated to your wallet");
            }
            else if (amount.integerValue > 0.f) {
                text = [NSString stringWithFormat:@"%@ %@ %@", L(@"Amount received:"), formattedAmount, baseUnit];
            }
            else {
                text = [NSString stringWithFormat:@"%@ %@ %@", L(@"Amount sent:"), formattedAmount, baseUnit];
            }
            cell.textLabel.text = text;
            break;
        }
        case SizeRow: {
            NSNumber *size = 0;
            if ([_handler respondsToSelector:@selector(size:)]) {
                size = [_handler size:nil];
            }
            cell.textLabel.text = [NSString stringWithFormat:L(@"%@ %@ bytes"), L(@"Size:"), size];
            break;
        }
        case FeeRow: {
            NSNumber *fee = 0;
            if ([_handler respondsToSelector:@selector(fee:)]) {
                fee = [_handler fee:nil];
            }
            NSString *formattedFee = nil;
            if ([_handler respondsToSelector:@selector(formattedFee:)]) {
                formattedFee = [_handler formattedFee:nil];
            }
            NSString *text = [NSString stringWithFormat:@"%@: %@", L(@"Fee"), (fee.integerValue == 0) ? L(@"unknown") : formattedFee];
            cell.textLabel.text = text;
            break;
        }
        default:
            break;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case InformationSection:
            return RowsCount;
        case InputsSection:
            return _inputs.count + 1;
        case OutputsSection:
            return _outputs.count + 1;
        default:
            return 0;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}

#pragma mark - Private Methods
- (void)updateInputsOutputs {
    NSString *inputsString = nil;
    NSString *outputsString = nil;
    if ([_handler respondsToSelector:@selector(inputsJson:)]) {
        inputsString = [_handler inputsJson:nil];
    }
    inputsString = [inputsString stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    if ([_handler respondsToSelector:@selector(outputsJson:)]) {
        outputsString = [_handler outputsJson:nil];
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

@end
