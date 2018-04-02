//
//  Localizer.h
//  Electrum
//
//  Created by Jasf on 24.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Localizer : NSObject
+ (NSString *)localize:(NSString *)string;
+ (NSString *)specialLocalize:(NSString *)string;
@end
