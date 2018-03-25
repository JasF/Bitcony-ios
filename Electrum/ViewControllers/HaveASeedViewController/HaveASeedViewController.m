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

@interface HaveASeedViewController ()
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation HaveASeedViewController {
    TextViewCell *_textViewCell;
}

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    [super viewDidLoad];
    self.view.backgroundColor = self.navigationController.view.backgroundColor;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ButtonCell" bundle:nil] forCellReuseIdentifier:@"ButtonCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LabelCell" bundle:nil] forCellReuseIdentifier:@"LabelCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TextViewCell" bundle:nil] forCellReuseIdentifier:@"TextViewCell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.f;
    self.title = L(@"Enter seed");
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
    if ([_handler respondsToSelector:@selector(continueTapped:)]) {
        [_handler continueTapped:_textViewCell.enteredText];
    }
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
#ifdef DEBUG
            NSData *data = [NSData dataWithContentsOfFile:@"/Users/jasf/Desktop/seed.h"];
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [cell setTextViewText:string];
#endif
            _textViewCell = cell;
            resultCell = cell;
            break;
        }
        case ContinueRow: {
            ButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
            [cell setTitle:L(@"Continue")];
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

@end
