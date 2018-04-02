//
//  Analytics.h
//  Electrum
//
//  Created by Jasf on 02.04.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Analytics : NSObject
+ (void)logEvent:(NSString *)eventName;
@end
