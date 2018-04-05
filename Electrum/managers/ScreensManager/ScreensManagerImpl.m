//
//  ScreensManagerImpl.m
//  Electrum
//
//  Created by Jasf on 19.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "EnterOrCreateWalletViewController.h"
#import "EnterWalletPasswordViewController.h"
#import "TransactionDetailViewController.h"
#import "CreateNewSeedViewController.h"
#import "CreateWalletViewController.h"
#import "ConfirmSeedViewController.h"
#import "BaseNavigationController.h"
#import "HaveASeedViewController.h"
#import "SettingsViewController.h"
#import "ReceiveViewController.h"
#import "HistoryViewController.h"
#import "WalletViewController.h"
#import "ServerViewController.h"
#import "MenuViewController.h"
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
@property (strong, nonatomic) WalletViewController *walletViewController;
@property (strong, nonatomic) HistoryViewController *historyViewController;
@property (strong, nonatomic) id<AlertManager> alertManager;
@property (strong, nonatomic) id<FeedbackManager> feedbackManager;
@property (strong, nonatomic) id<PythonBridge> pythonBridge;
@end

@implementation ScreensManagerImpl {
    id _menuHandler;
    id _mainHandler;
}

@synthesize window;
@synthesize pushControllerCallback = _pushControllerCallback;

#pragma mark - Initialization
- (id)initWithAlertManager:(id<AlertManager>)alertManager
           feedbackManager:(id<FeedbackManager>)feedbackManager
              pythonBridge:(id<PythonBridge>)pythonBridge {
    NSCParameterAssert(alertManager);
    NSCParameterAssert(feedbackManager);
    NSCParameterAssert(pythonBridge);
    if (self = [super init]) {
        _alertManager = alertManager;
        _feedbackManager = feedbackManager;
        _pythonBridge = pythonBridge;
        [_pythonBridge setClassHandler:self name:@"ScreensManager"];
    }
    return self;
}

#pragma mark - Overriden Methods - ScreensManager
- (void)showCreateWalletViewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CreateWalletViewController"
                                                             bundle:nil];
        CreateWalletViewController *viewController = (CreateWalletViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        viewController.handler = [self.pythonBridge handlerWithProtocol:@protocol(CreateWalletHandlerProtocol)];
        [navigationController pushViewController:viewController animated:YES];
    });
}

- (void)showEnterOrCreateWalletViewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"EnterOrCreateWalletViewController"
                                                             bundle:nil];
        UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];
        EnterOrCreateWalletViewController *viewController = (EnterOrCreateWalletViewController *)navigationController.topViewController;
        viewController.handler = [self.pythonBridge handlerWithProtocol:@protocol(EnterOrCreateWalletHandlerProtocol)];
        self.window.rootViewController = navigationController;
    });
}

- (void)showCreateNewSeedViewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CreateNewSeedViewController"
                                                             bundle:nil];
        CreateNewSeedViewController *viewController = (CreateNewSeedViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        viewController.handler = [self.pythonBridge handlerWithProtocol:@protocol(CreateNewSeedHandlerProtocol)];
        [navigationController pushViewController:viewController animated:YES];
    });
}

- (void)showHaveASeedViewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HaveASeedViewController"
                                                             bundle:nil];
        HaveASeedViewController *viewController = (HaveASeedViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        viewController.handler = [self.pythonBridge handlerWithProtocol:@protocol(HaveASeedHandlerProtocol)];
        [navigationController pushViewController:viewController animated:YES];
    });
}

- (void)showConfirmSeedViewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ConfirmSeedViewController"
                                                             bundle:nil];
        ConfirmSeedViewController *viewController = (ConfirmSeedViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        viewController.handler = [self.pythonBridge handlerWithProtocol:@protocol(ConfirmSeedHandlerProtocol)];
        [navigationController pushViewController:viewController animated:YES];
    });
}

- (void)showEnterWalletPasswordViewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"EnterWalletPasswordViewController"
                                                             bundle:nil];
        EnterWalletPasswordViewController *viewController = (EnterWalletPasswordViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        viewController.handler = [self.pythonBridge handlerWithProtocol:@protocol(EnterWalletPasswordHandlerProtocol)];
        [navigationController pushViewController:viewController animated:YES];
    });
}

- (UIViewController *)createHistoryViewController:(id)handler {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HistoryViewController"
                                                         bundle:nil];
    HistoryViewController *viewController = (HistoryViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    viewController.handler = (id<HistoryHandlerProtocol>)handler;
    viewController.pythonBridge = self.pythonBridge;
    viewController.alertManager = self.alertManager;
    viewController.screensManager = self;
    return viewController;
}

- (UIViewController *)createReceiveViewController:(id)handler {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ReceiveViewController"
                                                         bundle:nil];
    ReceiveViewController *viewController = (ReceiveViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    viewController.handler = (id<ReceiveHandlerProtocol>)handler;
    viewController.screensManager = self;
    return viewController;
}

- (UIViewController *)createSendViewController:(id)handler {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SendViewController"
                                                         bundle:nil];
    SendViewController *viewController = (SendViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    viewController.handler = (id<SendHandlerProtocol>)handler;
    viewController.screensManager = self;
    viewController.pythonBridge = self.pythonBridge;
    viewController.alertManager = self.alertManager;
    return viewController;
}

- (void)showWalletViewController {
    _menuHandler = [self.pythonBridge handlerWithProtocol:@protocol(MenuHandlerProtocol)];
    _mainHandler = [self.pythonBridge handlerWithProtocol:@protocol(MainWindowHandlerProtocol)];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.window.rootViewController = [self mainViewController];
        NSCAssert([self.window.rootViewController isEqual:[self mainViewController]], @"Excpected mainViewController as rootViewController");
        if (![self.window.rootViewController isEqual:_mainViewController]) {
            return;
        }
        [self closeMenu];
        if ([self canIgnorePushingViewController:[WalletViewController class]]) {
            return;
        }
        WalletViewController *viewController = self.walletViewController;
        if (!viewController) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"WalletViewController"
                                                                 bundle:nil];
            viewController = (WalletViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
            viewController.pageViewController = [storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
            viewController.screensManager = self;
            viewController.pythonBridge = self.pythonBridge;
            viewController.historyHandler = [self.pythonBridge handlerWithProtocol:@protocol(HistoryHandlerProtocol)];
            viewController.receiveHandler = [self.pythonBridge handlerWithProtocol:@protocol(ReceiveHandlerProtocol)];
            viewController.sendHandler = [self.pythonBridge handlerWithProtocol:@protocol(SendHandlerProtocol)];
            viewController.mainHandler = _mainHandler;
            _walletViewController = viewController;
        }
        [self pushViewController:viewController];
    });
}

- (void)showSettingsViewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self closeMenu];
        if ([self canIgnorePushingViewController:[SettingsViewController class]]) {
            return;
        }
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SettingsViewController"
                                                             bundle:nil];
        SettingsViewController *viewController = (SettingsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        viewController.handler = [self.pythonBridge handlerWithProtocol:@protocol(SettingsHandlerProtocol)];
        viewController.screensManager = self;
        [self pushViewController:viewController];
    });
}

- (void)showTransactionDetailViewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TransactionDetailViewController"
                                                             bundle:nil];
        TransactionDetailViewController *viewController = (TransactionDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        viewController.handler = [self.pythonBridge handlerWithProtocol:@protocol(TransactionDetailHandlerProtocol)];
        [self pushViewController:viewController clean:NO];
    });
}

- (void)showMenuViewController {
    [Analytics logEvent:@"MenuDidOpen"];
    MenuViewController *viewController = (MenuViewController *)self.mainViewController.leftViewController;
    viewController.handler = _menuHandler;
    [self.mainViewController showLeftViewAnimated:YES completionHandler:^{}];
}

- (void)showServerViewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ServerViewController"
                                                             bundle:nil];
        ServerViewController *viewController = (ServerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        viewController.pythonBridge = self.pythonBridge;
        viewController.handler = [self.pythonBridge handlerWithProtocol:@protocol(ServerHandlerProtocol)];
        [self pushViewController:viewController clean:NO];
    });
}

- (UIViewController *)topViewController {
    UIViewController *result = self.navigationController.topViewController;
    if (!result) {
        result = self.window.rootViewController;
    }
    return result;
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
    [self pushViewController:viewController clean:YES];
}

- (void)pushViewController:(UIViewController *)viewController clean:(BOOL)clean {
    if ([self allowReplaceWithViewController:viewController]) {
        self.navigationController.viewControllers = @[viewController];
    }
    else {
        [self.navigationController pushViewController:viewController animated:YES completion:^{
            if (self.pushControllerCallback) {
                self.pushControllerCallback();
                self.pushControllerCallback = nil;
            }
            if (clean && self.navigationController.viewControllers.count > 1) {
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
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
    self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    [self.window makeKeyAndVisible];
}

@end
