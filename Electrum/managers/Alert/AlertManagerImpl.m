//
//  AlertManagerImpl.m
//  Electrum
//
//  Created by Jasf on 23.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "AlertManagerImpl.h"

@interface AlertManagerImpl () <AlertManager>
@end

@implementation AlertManagerImpl

#pragma mark - Overriden Methods - AlertManager
- (void)show:(NSString *)message {
    NSCParameterAssert(_screensManager);
    UIViewController *viewController = self.screensManager.topViewController;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:L(@"OK")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [viewController presentViewController:alert animated:YES completion:nil];
}

@end
