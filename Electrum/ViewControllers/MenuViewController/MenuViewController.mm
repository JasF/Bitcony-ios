//
//  MenuViewController.m
//  Horoscopes
//
//  Created by Jasf on 05.11.2017.
//  Copyright © 2017 Mail.Ru. All rights reserved.
//

#import "LGSideMenuController.h"
#import "MenuViewController.h"

typedef NS_ENUM(NSInteger, MenuRows) {
    SimpleRow,
    RowsCount
};

static CGFloat const kGenericOffset = 8.f;
static CGFloat const kHoroscopeCellBottomOffset = 8.f;

static CGFloat const kRowHeight = 40.f;
static CGFloat const kHeaderViewHeight = 20.f;
static CGFloat const kSeparatorAlpha = 0.25f;

@interface MenuViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation MenuViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorColor = [[UIColor whiteColor] colorWithAlphaComponent:kSeparatorAlpha];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:LGSideMenuDidHideLeftViewNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect frame = self.view.bounds;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    frame.size.width = [UIScreen mainScreen].bounds.size.width;
    frame.size.height += statusBarHeight;
    frame.origin.y -= statusBarHeight;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
    cell.textLabel.text = @"Simple label";
    return cell;
    /*
    MenuSimpleCell *cell = nil;
    cell.delegate = self;
    if (indexPath.row == ZodiacsRow) {
        ZodiacsCell *zodiacsCell = [tableView dequeueReusableCellWithIdentifier:kZodiacsCell];
        [zodiacsCell setZodiacsLayoutController:_zodiacsLayoutController];
        auto zodiacs = _viewModel->zodiacsTitlesAndImageNames();
        NSMutableArray *zodiacsArray = [NSMutableArray new];
        for (dictionary dict : zodiacs) {
            NSDictionary *dictionary = [NSDictionary horo_dictionaryFromJsonValue:dict];
            [zodiacsArray addObject:dictionary];
        }
        [zodiacsCell setItems:[zodiacsArray copy]];
        return zodiacsCell;
    }
    else {
        cell =(MenuSimpleCell *)[tableView dequeueReusableCellWithIdentifier:kMenuSimpleCell];
        NSCParameterAssert(cell);
        NSDictionary *titles = @{@(PredictionRow):@"menu_cell_prediction",
                                 @(FriendsRow):@"menu_cell_friends",
                                 @(AccountRow):@"menu_cell_account",
                                 @(NotifcationsRow):@"menu_cell_notifications",
                                 @(FeedbackRow):@"menu_cell_feedback",
                                 @(PromoRow):@"menu_cell_promo",
                                 };
        NSString *title = L(titles[@(indexPath.row)]);
        NSCParameterAssert(title.length);
        [cell setText:title];
        if (indexPath.row == PromoRow) {
            [cell setImage:[UIImage imageNamed:@"redpill"]];
        }
    }
    NSDictionary *bottomOffsets = @{@(PredictionRow) : @(kHoroscopeCellBottomOffset)};
    NSNumber *value = bottomOffsets[@(indexPath.row)];
    CGFloat offset = (value) ? value.floatValue : kGenericOffset;
    [cell setOffset:offset];
    return cell;
    */
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeaderViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

#pragma mark - Observers
- (void)menuDidHide:(id)sender {
    [self.tableView reloadData];
    self.tableView.contentOffset = CGPointZero;
}

@end
