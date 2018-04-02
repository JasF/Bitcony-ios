//
//  ConfirmSeedViewController.m
//  Electrum
//
//  Created by Jasf on 20.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "ConfirmSeedViewController.h"
#import "TextViewCell.h"
#import "ButtonCell.h"
#import "LabelCell.h"

typedef NS_ENUM(NSInteger, Rows) {
    DescriptionRow,
    TextViewRow,
    ContinueRow,
    RowsCount
};

@interface ConfirmSeedViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>
@end

@implementation ConfirmSeedViewController {
    NSString *_seed;
    NSString *_originalSeed;
    ButtonCell *_continueCell;
}

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    [Analytics logEvent:@"ConfirmSeedScreenDidLoad"];
    [super viewDidLoad];
    self.view.backgroundColor = self.navigationController.view.backgroundColor;
    _originalSeed = [_handler generatedSeed];
#ifdef DEBUG
    _seed = _originalSeed;
#endif
    [self.tableView registerNib:[UINib nibWithNibName:@"ButtonCell" bundle:nil] forCellReuseIdentifier:@"ButtonCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LabelCell" bundle:nil] forCellReuseIdentifier:@"LabelCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TextViewCell" bundle:nil] forCellReuseIdentifier:@"TextViewCell"];
    self.title = L(@"Confirm Seed");
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.f;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
#if AUTO_FORWARD == 1
    [self continueTapped:nil];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)continueTapped:(id)sender {
    dispatch_python(^{
        if ([_handler respondsToSelector:@selector(continueTapped:)]) {
            [_handler continueTapped:nil];
        }
    });
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *resultCell = nil;
    switch (indexPath.row) {
        case DescriptionRow: {
            LabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LabelCell"];
            NSString *text = [NSString stringWithFormat:@"%@ %@ %@",
                              L(@"Your seed is important!"),
                              L(@"If you lose your seed, your money will be permanently lost."),
                              L(@"To make sure that you have properly saved your seed, please retype it here.")];
            [cell setTitle:text];
            resultCell = cell;
            break;
        }
        case TextViewRow: {
            TextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextViewCell"];
            cell.textView.delegate = self;
            cell.textView.keyboardType = UIKeyboardTypeASCIICapable;
            [cell setTextViewText:_seed];
            resultCell = cell;
            break;
        }
        case ContinueRow: {
            ButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
            _continueCell = cell;
            [cell setButtonEnabled:[self checkSeed]];
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
    return UITableViewAutomaticDimension;
}

#pragma mark - Private Methods
- (BOOL)checkSeed {
    return [_originalSeed isEqualToString:_seed];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:textView action:@selector(resignFirstResponder)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];
    textView.inputAccessoryView = toolbar;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    _seed = [textView.text stringByReplacingCharactersInRange:range withString:text];
    [_continueCell setButtonEnabled:[self checkSeed]];
    return YES;
}

@end
