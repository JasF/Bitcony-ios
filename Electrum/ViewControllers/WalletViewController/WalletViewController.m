//
//  WalletViewController.m
//  Electrum
//
//  Created by Jasf on 21.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "WalletViewController.h"
#import "Tabs.h"

typedef NS_ENUM(NSInteger, TabsDefinitions) {
    TabSend,
    TabHistory,
    TabReceive,
    TabsCount
};

@interface WalletViewController ()
@property (weak, nonatomic) IBOutlet Tabs *tabs;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@end

@implementation WalletViewController {
    NSTimer *_timer;
}

- (void)viewDidLoad {
    NSCParameterAssert(_screensManager);
    NSCParameterAssert(_pageViewController);
    NSCParameterAssert(_historyViewController);
    [super viewDidLoad];
    
    @weakify(self);
    _tabs.tabsItemViewSelected = ^(NSInteger previousIndex, NSInteger currentIndex) {
        @strongify(self);
        DDLogInfo(@"prev: %@; cur: %@", @(previousIndex), @(currentIndex));
    };
    _tabs.titles = @[L(@"Send"), L(@"History"), L(@"Receive")];
    [self.tabs setItemSelected:TabHistory
                     animation:TabsAnimationNone
                    withNotify:NO];
    
    [_historyViewController willMoveToParentViewController:self];
    [self addChildViewController:_historyViewController];
    [self.contentView utils_addFillingSubview:_historyViewController.view];
    [_historyViewController didMoveToParentViewController:self];
}

#pragma mark - Observers
- (IBAction)menuTapped:(id)sender {
    [_screensManager showMenuViewController];
}

@end
