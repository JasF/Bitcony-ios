//
//  CreateWalletViewController.m
//  Electrum
//
//  Created by Jasf on 19.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "CreateWalletViewController.h"
#import "ButtonCell.h"
#import "LabelCell.h"

typedef NS_ENUM(NSInteger, Rows) {
    DescriptionRow,
    CreateSeedRow,
    ExistedSeedRow,
    RowsCount
};

static CGFloat const kEstimatedRowHeight = 50.f;

@interface CreateWalletViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIButton *createNewSeedButton;
@property (strong, nonatomic) IBOutlet UIButton *haveASeedButton;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@end

@implementation CreateWalletViewController

- (void)viewDidLoad {
    NSCParameterAssert(_handler);
    [Analytics logEvent:@"CreateWalletScreenDidLoad"];
    [super viewDidLoad];
    self.view.backgroundColor = self.navigationController.view.backgroundColor;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = kEstimatedRowHeight;
    [self.tableView registerNib:[UINib nibWithNibName:@"ButtonCell" bundle:nil] forCellReuseIdentifier:@"ButtonCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LabelCell" bundle:nil] forCellReuseIdentifier:@"LabelCell"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
#if AUTO_FORWARD == 1
    [self createNewSeedTapped:nil];
#elif AUTO_FORWARD == 2
    [self haveASeedTapped:nil];
#endif
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)createNewSeedTapped:(id)sender {
    if ([_handler respondsToSelector:@selector(createNewSeedTapped:)]) {
        [_handler createNewSeedTapped:nil];
    }
}

- (IBAction)haveASeedTapped:(id)sender {
    if ([_handler respondsToSelector:@selector(haveASeedTapped:)]) {
        [_handler haveASeedTapped:nil];
    }
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *resultCell = nil;
    switch (indexPath.row) {
        case DescriptionRow: {
            LabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LabelCell"];
            [cell setTitle:L(@"Do you want to create a new seed, or to restore a wallet using an existing seed?")];
            resultCell = cell;
            break;
        }
        case CreateSeedRow: {
            ButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
            [cell setTitle:L(@"Create a new seed")];
            @weakify(self);
            cell.tappedHandler = ^{
                @strongify(self);
                [self createNewSeedTapped:nil];
            };
            [cell setDelimeterVisible:YES];
            resultCell = cell;
            break;
        }
        case ExistedSeedRow: {
            ButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
            [cell setTitle:L(@"I already have a seed")];
            @weakify(self);
            cell.tappedHandler = ^{
                @strongify(self);
                [self haveASeedTapped:nil];
            };
            [cell setDelimeterVisible:NO];
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end
