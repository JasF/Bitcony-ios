//
//  YesNoDialog.h
//  Electrum
//
//  Created by Jasf on 24.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>

@protocol YesNoDialog <NSObject>
- (void)showWithMessage:(NSString *)message;
@end
