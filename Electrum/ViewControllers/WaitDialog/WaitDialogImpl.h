//
//  WaitDialogImpl.h
//  Electrum
//
//  Created by Jasf on 23.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WaitDialog.h"

@interface WaitDialogImpl : NSObject <WailDialog>
- (void)showInView:(UIView *)view withMessage:(NSString *)message;
- (void)close;
@end
