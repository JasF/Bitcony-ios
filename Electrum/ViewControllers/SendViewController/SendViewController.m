//
//  SendViewController.m
//  Electrum
//
//  Created by Jasf on 22.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "SendViewController.h"
#import "TextFieldCell.h"
#import "ButtonCell.h"
#import "FeeCell.h"

typedef NS_ENUM(NSInteger, Rows) {
    PayToRow,
    PayToValueRow,
    DescriptionRow,
    DescriptionValueRow,
    AmountRow,
    AmountValueRow,
    FeeRow,
    FeeSliderRow,
    FeeDescriptionRow,
    ClearRow,
    PreviewRow,
    SendRow,
    RowsCount
};

static CGFloat const kRowHeight = 44.f;
static CGFloat const kNumberOfSliderSteps = 5.f - 1.f;

@interface SendViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) FeeCell *feeCell;
@end

@implementation SendViewController {
    NSString *_feeDescription;
}

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    NSCParameterAssert(_screensManager);
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"SimpleCell" bundle:nil] forCellReuseIdentifier:@"SimpleCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TextFieldCell" bundle:nil] forCellReuseIdentifier:@"TextFieldCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TableButtonCell" bundle:nil] forCellReuseIdentifier:@"TableButtonCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FeeCell" bundle:nil] forCellReuseIdentifier:@"FeeCell"];
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
    }
    else if ([buttonCells containsObject:@(indexPath.row)]) {
        buttonCell = [tableView dequeueReusableCellWithIdentifier:@"TableButtonCell"];
        cell = buttonCell;
    }
    
    switch (indexPath.row) {
        case PayToRow: {
            cell.textLabel.text = L(@"Pay to");
            break;
        }
        case PayToValueRow: {
            break;
        }
        case DescriptionRow: {
            cell.textLabel.text = L(@"Description");
            break;
        }
        case DescriptionValueRow: {
            break;
        }
        case AmountRow: {
            cell.textLabel.text = L(@"Amount");
            break;
        }
        case AmountValueRow: {
            break;
        }
        case FeeRow: {
            cell.textLabel.text = L(@"Fee");
            break;
        }
        case FeeSliderRow: {
            return self.feeCell;
        }
        case FeeDescriptionRow: {
            cell.textLabel.text = _feeDescription;
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
    }
    
    NSCAssert(cell, @"Undefined cell not allowed");
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case ClearRow: {
            break;
        }
        case PreviewRow: {
            break;
        }
        case SendRow: {
            break;
        }
        default:
            break;
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
        _feeDescription = newLine;
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:FeeDescriptionRow inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

@end
