//
//  TextFieldDialog.h
//  Electrum
//
//  Created by Jasf on 25.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>

@protocol TextFieldDialog <NSObject>
- (void)showWithMessage:(NSString *)message placeholder:(NSString *)placeholder;
@end
