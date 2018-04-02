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
    return NSLocalizedString(string, nil);
}

+ (NSString *)translateSubstringInString:(NSString *)string {
    NSRange begin = [string rangeOfString:@"|>"];
    if (begin.location != NSNotFound) {
        NSRange end = [string rangeOfString:@"<|"];
        if (end.location != NSNotFound) {
            NSString *substring = [string substringWithRange:NSMakeRange(begin.location + 2, end.location - begin.location - 2)];
            substring = L(substring);
            string = [string stringByReplacingCharactersInRange:NSMakeRange(begin.location, end.location - begin.location + 2) withString:substring];
        }
    }
    return string;
}

+ (NSString *)specialLocalize:(NSString *)string {
    while (YES) {
        NSString *newString = [self translateSubstringInString:string];
        if ([newString isEqualToString:string]) {
            string = newString;
            break;
        }
        string = newString;
    }
    return string;
}
@end
