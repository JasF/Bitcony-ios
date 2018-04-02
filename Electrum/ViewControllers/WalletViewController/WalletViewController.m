//
//  WalletViewController.m
//  Electrum
//
//  Created by Jasf on 21.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "WalletViewController.h"
#import "TitleView.h"
#import "Tabs.h"

typedef NS_ENUM(NSInteger, TabsDefinitions) {
    TabSend,
    TabHistory,
    TabReceive,
    TabsCount
};

@interface WalletViewController () <UIPageViewControllerDelegate,
                                    UIPageViewControllerDataSource,
                                    UIScrollViewDelegate,
                                    MainWindowHandlerProtocolDelegate>
@property (weak, nonatomic) IBOutlet Tabs *tabs;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) NSMutableDictionary *viewControllers;
@property (weak, nonatomic) UIViewController *selectedViewController;

@property (copy, nonatomic, nullable) void (^draggingProgress)(CGFloat completed, Direction direction);
@property (copy, nonatomic, nullable) void (^selectedPageChanged)(NSInteger previous, NSInteger current);
@property (copy, nonatomic, nullable) dispatch_block_t didEndDeceleratingBlock;
@property (copy, nonatomic, nullable) dispatch_block_t didEndScrollingAnimationBlock;
@property (assign, nonatomic) BOOL allowCustomAnimationWithTabs;
@property (weak, nonatomic) IBOutlet UIButton *rightNavigationItemButton;

@end

@implementation WalletViewController {
    NSTimer *_timer;
    NSString *_baseUnit;
}

- (void)viewDidLoad {
    NSCParameterAssert(_screensManager);
    NSCParameterAssert(_pageViewController);
    NSCParameterAssert(_historyHandler);
    NSCParameterAssert(_receiveHandler);
    NSCParameterAssert(_sendHandler);
    NSCParameterAssert(_mainHandler);
    [super viewDidLoad];
    [_pythonBridge setClassHandler:self name:@"MainWindowHandlerProtocolDelegate"];
    if ([_historyHandler respondsToSelector:@selector(viewDidLoad)]) {
        [_historyHandler viewDidLoad];
    }
    _viewControllers = [NSMutableDictionary new];
    self.allowCustomAnimationWithTabs = YES;
    [self initializePageViewController];
    [self initializeTabs];
    
    [_pageViewController willMoveToParentViewController:self];
    [self addChildViewController:_pageViewController];
    [self.contentView utils_addFillingSubview:_pageViewController.view];
    [_pageViewController didMoveToParentViewController:self];
    [self initializeTitleView];
    self.rightNavigationItemButton.userInteractionEnabled = NO;
    [self updateIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateIfNeeded];
}

- (void)updateIfNeeded {
    NSString *baseUnit = nil;
    if ([_mainHandler respondsToSelector:@selector(baseUnit:)]) {
        baseUnit = [_mainHandler baseUnit:nil];
    }
    if (!_baseUnit) {
        _baseUnit = baseUnit;
    }
    else if (![_baseUnit isEqualToString:baseUnit]) {
        _baseUnit = baseUnit;
        dispatch_python(^{
            if ([_mainHandler respondsToSelector:@selector(updateStatus:)]) {
                [_mainHandler updateStatus:nil];
            }
        });
    }
}

- (void)initializeTitleView {
    self.navigationItem.titleView = [[NSBundle mainBundle] loadNibNamed:@"TitleView"
                                                                  owner:nil
                                                                options:nil].firstObject;
}

- (void)initializePageViewController {
    @weakify(self);
    self.draggingProgress = ^(CGFloat completed, Direction direction) {
        @strongify(self);
        if (self.allowCustomAnimationWithTabs) {
            [self.tabs animateSelection:direction patchCompleted:completed];
        }
    };
    self.selectedPageChanged = ^(NSInteger previous, NSInteger current) {
        @strongify(self);
        [self.tabs setItemSelected:current animation:TabsAnimationFrameOnly];
    };
}

- (void)initializeTabs {
    @weakify(self);
    _tabs.tabsItemViewSelected = ^(NSInteger previousIndex, NSInteger currentIndex) {
        @strongify(self);
        self.allowCustomAnimationWithTabs = NO;
        [self setSelectedIndex:currentIndex
                    completion:^{
                        @strongify(self);
                        self.allowCustomAnimationWithTabs = YES;
                    }];
    };
    
    _tabs.titles = @[L(@"Send"), L(@"History"), L(@"Receive")];
    [self.tabs setItemSelected:TabHistory
                     animation:TabsAnimationNone
                    withNotify:NO];
    
    [self showViewControllerByIndex:TabHistory];
}

- (void)showViewControllerByIndex:(NSInteger)index {
    UIViewController *viewController = [self viewControllerByIndex:index];
    _selectedViewController = viewController;
    [_pageViewController setViewControllers:@[viewController]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
}

#pragma mark - Observers
- (IBAction)menuTapped:(id)sender {
    [_screensManager showMenuViewController];
}

#pragma mark - Private Methods
- (UIScrollView *)scrollView {
    for (UIView *view in _pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            return(UIScrollView *)view;
        }
    }
    return nil;
}

- (NSArray *)texts {
    return self.tabs.titles;
}

#pragma mark - Accessors
- (void)setPageViewController:(UIPageViewController *)pageViewController {
    [[self scrollView] setDelegate:nil];
    _pageViewController = pageViewController;
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    [[self scrollView] setDelegate:self];
    _pageViewController.view.clipsToBounds = NO;
    [self scrollView].clipsToBounds = NO;
}

#pragma mark - UIPageViewControllerDataSource
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    // DDLogDebug(@"pageViewController:viewControllerBeforeViewController %@", @(viewController.index));
    if (!viewController.index) {
        return nil;
    }
    return [self viewControllerByIndex:viewController.index - 1];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    // DDLogDebug(@"pageViewController:viewControllerAfterViewController %@", @(viewController.index));
    if (viewController.index >= self.texts.count-1) {
        return nil;
    }
    return [self viewControllerByIndex:viewController.index + 1];
}

- (UIViewController *)viewControllerByIndex:(NSInteger)index {
    // DDLogDebug(@"viewControllerByIndex: %@", @(index));
    UIViewController *resultViewController = _viewControllers[@(index)];
    if (!resultViewController) {
        resultViewController = [self allocateViewControllerWithIndex:index];
    }
    return resultViewController;
}

- (UIViewController *)allocateViewControllerWithIndex:(NSInteger)index {
    UIViewController *viewController = nil;
    switch (index) {
        case TabSend: {
            viewController = [_screensManager createSendViewController:_sendHandler];
            break;
        }
        case TabHistory: {
            viewController = [_screensManager createHistoryViewController:_historyHandler];
            break;
        }
        case TabReceive: {
            viewController = [_screensManager createReceiveViewController:_receiveHandler];
            break;
        }
        default: {
            NSCAssert(NO, @"Unhandled index: %@", @(index));
            break;
        }
    }
    viewController.index = index;
    [_viewControllers setObject:viewController forKey:@(index)];
    return viewController;
}

#pragma mark - UIPageViewControllerDelegate
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (!completed) {
        return;
    }
    // DDLogDebug(@"pageViewController:didFinishAnimating:previousViewControllers:transitionCompleted: %@", @(completed));
    UIViewController *viewController = _pageViewController.viewControllers.firstObject;
    if ([_selectedViewController isEqual:viewController]) {
        return;
    }
    NSInteger previous = _selectedViewController.index;
    _selectedViewController = viewController;
    DDLogInfo(@"Selected page changed: %@", @(_selectedViewController.index));

    if (_selectedPageChanged) {
        _selectedPageChanged(previous, _selectedViewController.index);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    Direction direction = (scrollView.contentOffset.x > scrollView.width) ? DirectionForwardToLeft : DirectionBackToRight;
    CGFloat delta = (direction == DirectionForwardToLeft) ? scrollView.contentOffset.x - scrollView.width : scrollView.width - scrollView.contentOffset.x;
    if (IsEqualFloat(0, delta)) {
        return;
    }
    CGFloat percentage = delta / scrollView.width;
    if (_draggingProgress) {
        _draggingProgress(percentage, direction);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // DDLogDebug(@"page scrollViewDidEndDecelerating");
    if (_didEndDeceleratingBlock) {
        _didEndDeceleratingBlock();
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (_didEndScrollingAnimationBlock) {
        _didEndScrollingAnimationBlock();
    }
}

#pragma mark - Public Methods
- (void)setSelectedIndex:(NSInteger)index completion:(dispatch_block_t)completion {
    // DDLogDebug(@"page setSelectedIndex: %@ completion:", @(index));
    if (_selectedViewController.index == index) {
        if (completion) {
            completion();
        }
        return;
    }
    UIPageViewControllerNavigationDirection direction = (index > _selectedViewController.index) ? UIPageViewControllerNavigationDirectionForward: UIPageViewControllerNavigationDirectionReverse;
    UIViewController *nextViewController = [self viewControllerByIndex:index];
    NSCAssert(nextViewController, @"ViewController must be allocated");
    if (!nextViewController) {
        if (completion) {
            completion();
        }
        return;
    }
    @weakify(self);
    [_pageViewController setViewControllers:@[nextViewController]
                                  direction:direction
                                   animated:YES
                                 completion:^(BOOL finished) {
                                     @strongify(self);
                                     self.selectedViewController = nextViewController;
                                     if (completion) {
                                         completion();
                                     }
                                 }];
}

#pragma mark - MainWindowHandlerProtocolDelegate
- (void)updateBalance:(NSString *)balanceString
             iconName:(NSString *)iconName {
    dispatch_async(dispatch_get_main_queue(), ^{
        TitleView *titleView = (TitleView *)self.navigationItem.titleView;
        NSDictionary *sizes = @{@(3):@(12.f), @(2):@(14.f), @(1):@(19.f)};
        CGFloat fontSize = [sizes[@([balanceString componentsSeparatedByString:@"\n"].count)] floatValue];
        if (IsEqualFloat(fontSize, 0.f)) {
            fontSize = 12.f;
        }
        titleView.font = [UIFont systemFontOfSize:fontSize];
        titleView.text = SL(balanceString);
        [self.rightNavigationItemButton setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
        self.rightNavigationItemButton.imageView.contentMode = UIViewContentModeCenter;
        self.rightNavigationItemButton.imageView.transform = CGAffineTransformMakeScale(.75f, .75f);
    });
}

@end
