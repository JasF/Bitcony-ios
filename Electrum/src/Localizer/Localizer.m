//
//  Localizer.m
//  Electrum
//
//  Created by Jasf on 24.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "Localizer.h"

@implementation Localizer
+ (NSString *)localize:(NSString *)string {
    return L(string);
}
@end
