//
//  BaseNavigationController.m
//  Horoscopes
//
//  Created by Jasf on 26.11.2017.
//  Copyright © 2017 Mail.Ru. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController () <UINavigationControllerDelegate>
@property (copy, nonatomic) dispatch_block_t completion;
@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    self.view.backgroundColor = RGB(24, 24, 24);
    [super viewDidLoad];
    self.delegate = self;
    self.navigationBar.translucent = YES;
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Public Methods
- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
                completion:(dispatch_block_t)completion {
    _completion = completion;
    [self pushViewController:viewController animated:animated];
}

#pragma mark - UINavigationControllerDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    /*
    if (_themesManager->activeTheme()->nativeNavigationTransition()) {
        return nil;
    }
    NSDictionary *dictionary = @{
        @(UINavigationControllerOperationPush):[PushAnimator class],
        @(UINavigationControllerOperationPop):[PopAnimator class]
    };
    Class animatorClass = dictionary[@(operation)];
    NSCAssert(animatorClass, @"Animator for operation: %@ not found", @(operation));
    if (!animatorClass) {
        return nil;
    }
    return [animatorClass new];
     */
    return nil;
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    if (_completion) {
        _completion();
        _completion = nil;
    }
}

@end
