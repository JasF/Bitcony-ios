//
//  HaveASeedViewController.m
//  Electrum
//
//  Created by Jasf on 20.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "HaveASeedViewController.h"
#import "TextViewCell.h"
#import "ButtonCell.h"
#import "LabelCell.h"

typedef NS_ENUM(NSInteger, Rows) {
    DescriptionRow,
    TextViewRow,
    ContinueRow,
    RowsCount
};

@interface HaveASeedViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation HaveASeedViewController {
    NSString *_seed;
    ButtonCell *_continueCell;
}

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    [Analytics logEvent:@"HaveASeedScreenDidLoad"];
    [super viewDidLoad];
    self.view.backgroundColor = self.navigationController.view.backgroundColor;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ButtonCell" bundle:nil] forCellReuseIdentifier:@"ButtonCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LabelCell" bundle:nil] forCellReuseIdentifier:@"LabelCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TextViewCell" bundle:nil] forCellReuseIdentifier:@"TextViewCell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.f;
    self.title = L(@"Enter seed");
#ifdef DEBUG
    _seed = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:@"/Users/jasf/Desktop/seed.h"] encoding:NSUTF8StringEncoding];
#endif
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
- (IBAction)continueButtonTapped:(id)sender {
    dispatch_python(^{
        if ([_handler respondsToSelector:@selector(continueTapped:)]) {
            [_handler continueTapped:_seed];
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
        case TextViewRow: {
            TextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextViewCell"];
            cell.textView.delegate = self;
            [cell setTextViewText:_seed];
            resultCell = cell;
            break;
        }
        case ContinueRow: {
            ButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
            _continueCell = cell;
            [cell setTitle:L(@"Continue")];
            [cell setDelimeterVisible:NO];
            [cell setButtonEnabled:[self isSupportedSeed:_seed]];
            @weakify(self);
            cell.tappedHandler = ^{
                @strongify(self);
                [self continueButtonTapped:nil];
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
    [_continueCell setButtonEnabled:[self isSupportedSeed:_seed]];
    return YES;
}

#pragma mark - Private Methods
- (BOOL)isSupportedSeed:(NSString *)seed {
    NSString *seedType = nil;
    if ([_handler respondsToSelector:@selector(seedType:)]) {
        seedType = [_handler seedType:_seed.length ? _seed : @""];
    }
    return [seedType isEqualToString:@"standard"];
}

@end
