//
//  Analytics.m
//  Electrum
//
//  Created by Jasf on 02.04.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "Analytics.h"

@import FBSDKCoreKit;

@implementation Analytics
+ (void)logEvent:(NSString *)eventName {
    [FBSDKAppEvents logEvent:eventName];
}
@end
