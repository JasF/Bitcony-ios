//
//  ScreensManagerImpl.m
//  Electrum
//
//  Created by Jasf on 19.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "EnterOrCreateWalletViewController.h"
#import "EnterWalletPasswordViewController.h"
#import "CreateNewSeedViewController.h"
#import "CreateWalletViewController.h"
#import "ConfirmSeedViewController.h"
#import "BaseNavigationController.h"
#import "HaveASeedViewController.h"
#import "SettingsViewController.h"
#import "ReceiveViewController.h"
#import "WalletViewController.h"
#import "SendViewController.h"
#import "MainViewController.h"
#import "ScreensManagerImpl.h"
#import "ViewController.h"
#import "AppDelegate.h"

static NSInteger const kSlideMenuActivationMode = 8;
static NSString *kStoryboardName = @"Main";

@interface ScreensManagerImpl ()
@property (nonatomic, strong) BaseNavigationController *navigationController;
@property (strong, nonatomic) MainViewController *mainViewController;
@property (nonatomic, strong) UIStoryboard *storyboard;
@end

@implementation ScreensManagerImpl

@synthesize window;

#pragma mark - Initialization

#pragma mark - Overriden Methods - ScreensManager
- (void)showCreateWalletViewController:(id)handler {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CreateWalletViewController"
                                                             bundle:nil];
        CreateWalletViewController *viewController = (CreateWalletViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        viewController.handler = (id<CreateWalletHandlerProtocol>)handler;
        [navigationController pushViewController:viewController animated:YES];
    });
}

- (void)showEnterOrCreateWalletViewController:(id)handler {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self createWindowIfNeeded];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"EnterOrCreateWalletViewController"
                                                             bundle:nil];
        UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];
        EnterOrCreateWalletViewController *viewController = (EnterOrCreateWalletViewController *)navigationController.topViewController;
        viewController.handler = (id<EnterOrCreateWalletHandlerProtocol>)handler;
        self.window.rootViewController = navigationController;
    });
}

- (void)showCreateNewSeedViewController:(id)handler {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CreateNewSeedViewController"
                                                             bundle:nil];
        CreateNewSeedViewController *viewController = (CreateNewSeedViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        viewController.handler = (id<CreateNewSeedHandlerProtocol>)handler;
        [navigationController pushViewController:viewController animated:YES];
    });
}

- (void)showHaveASeedViewController:(id)handler {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HaveASeedViewController"
                                                             bundle:nil];
        HaveASeedViewController *viewController = (HaveASeedViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        viewController.handler = (id<HaveASeedHandlerProtocol>)handler;
        [navigationController pushViewController:viewController animated:YES];
    });
}

- (void)showConfirmSeedViewController:(id)handler {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ConfirmSeedViewController"
                                                             bundle:nil];
        ConfirmSeedViewController *viewController = (ConfirmSeedViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        viewController.handler = (id<ConfirmSeedHandlerProtocol>)handler;
        [navigationController pushViewController:viewController animated:YES];
    });
}

- (void)showEnterWalletPasswordViewController:(id)handler {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"EnterWalletPasswordViewController"
                                                             bundle:nil];
        EnterWalletPasswordViewController *viewController = (EnterWalletPasswordViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        viewController.handler = (id<EnterWalletPasswordHandlerProtocol>)handler;
        [navigationController pushViewController:viewController animated:YES];
    });
}

- (void)showMainViewController:(id)handler {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.window.rootViewController = [self mainViewController];
    });
}

- (void)showWalletViewController:(id)handler {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSCAssert([self.window.rootViewController isEqual:[self mainViewController]], @"Excpected mainViewController as rootViewController");
        if (![self.window.rootViewController isEqual:_mainViewController]) {
            return;
        }
        [self closeMenu];
        if ([self canIgnorePushingViewController:[WalletViewController class]]) {
            return;
        }
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"WalletViewController"
                                                             bundle:nil];
        WalletViewController *viewController = (WalletViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        viewController.handler = (id<WalletHandlerProtocol>)handler;
        viewController.screensManager = self;
        [self pushViewController:viewController];
    });
}

- (void)showReceiveViewController:(id)handler {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ReceiveViewController"
                                                             bundle:nil];
        WalletViewController *viewController = (WalletViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        viewController.handler = (id<WalletHandlerProtocol>)handler;
        viewController.screensManager = self;
        [self pushViewController:viewController];
    });
}

- (void)showSendViewController:(id)handler {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SendViewController"
                                                             bundle:nil];
        SendViewController *viewController = (SendViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        viewController.handler = (id<SendHandlerProtocol>)handler;
        viewController.screensManager = self;
        [self pushViewController:viewController];
    });
}

- (void)showSettingsViewController:(id)handler {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SettingsViewController"
                                                             bundle:nil];
        SettingsViewController *viewController = (SettingsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        viewController.handler = (id<SettingsHandlerProtocol>)handler;
        viewController.screensManager = self;
        [self pushViewController:viewController];
    });
}

- (void)showMenuViewController {
    [self.mainViewController showLeftViewAnimated:YES completionHandler:^{}];
}

#pragma mark - Private Methods
- (BOOL)canIgnorePushingViewController:(Class)cls {
    if ([[self.navigationController.topViewController class] isEqual:cls]) {
        return YES;
    }
    return NO;
}

- (void)closeMenu {
    if (![self.mainViewController isLeftViewHidden]) {
        [self.mainViewController hideLeftViewAnimated];
    }
}

- (BOOL)allowReplaceWithViewController:(UIViewController *)viewController {
    if (!self.navigationController.viewControllers.count) {
        return YES;
    }
    if (self.navigationController.viewControllers.count == 1 &&
        [self.navigationController.viewControllers.firstObject isKindOfClass:[ViewController class]]) {
        return YES;
    }
    return NO;
}

- (void)pushViewController:(UIViewController *)viewController {
    if ([self allowReplaceWithViewController:viewController]) {
        self.navigationController.viewControllers = @[viewController];
    }
    else {
        [self.navigationController pushViewController:viewController animated:YES completion:^{
            if (self.navigationController.viewControllers.count > 1) {
                self.navigationController.viewControllers = @[viewController];
            }
        }];
    }
}

- (MainViewController *)mainViewController {
    if (!_mainViewController) {
        BaseNavigationController *navigationController =(BaseNavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];
        _navigationController = navigationController;
        [navigationController setViewControllers:@[[self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"]]];
        _mainViewController = [_storyboard instantiateInitialViewController];
        _mainViewController.rootViewController = navigationController;
        [_mainViewController setupWithType:kSlideMenuActivationMode];
    }
    return _mainViewController;
}

- (UIStoryboard *)storyboard {
    if (!_storyboard) {
        _storyboard = [UIStoryboard storyboardWithName:kStoryboardName bundle:nil];
    }
    return _storyboard;
}

- (void)createWindowIfNeeded {
    if (self.window) {
        return;
    }
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [UIViewController new];
    [self.window makeKeyAndVisible];
}

@end
