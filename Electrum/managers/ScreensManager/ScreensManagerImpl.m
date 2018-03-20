//
//  ScreensManagerImpl.m
//  Electrum
//
//  Created by Jasf on 19.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "ScreensManagerImpl.h"
#import "EnterOrCreateWalletViewController.h"
#import "AppDelegate.h"

@implementation ScreensManagerImpl {
    dispatch_group_t _group;
}

@synthesize window;

#pragma mark - Overriden Methods - ScreensManager
- (void)showCreateWalletViewController {
    [self createWindowIfNeeded];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"EnterOrCreateWalletViewController"
                                                         bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];
    self.window.rootViewController = navigationController;
}

- (void)showEnterOrCreateWalletViewController {
    _group = dispatch_group_create();
    dispatch_group_enter(_group);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self createWindowIfNeeded];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"EnterOrCreateWalletViewController"
                                                             bundle:nil];
        UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];
        self.window.rootViewController = navigationController;
    });
}

- (void)loopExec {
    dispatch_group_wait(_group, DISPATCH_TIME_FOREVER);
    //[[NSRunLoop mainRunLoop] run];
    //[self ];
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
