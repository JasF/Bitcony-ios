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
#import "HaveASeedViewController.h"
#import "ScreensManagerImpl.h"
#import "AppDelegate.h"

@implementation ScreensManagerImpl {
}

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

#pragma mark - Private Methods
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
