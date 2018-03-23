//
//  AlertManager.h
//  Electrum
//
//  Created by Jasf on 23.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>

@protocol AlertManager <NSObject>
- (void)show:(NSString *)message;
@end
