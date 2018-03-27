//
//  ReceiveSharingObject.h
//  Receives
//
//  Created by Jasf on 25.01.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#include "SharingObject.h"

@interface ReceiveSharingObject : NSObject <SharingObject>
- (id)initWithMessage:(NSString *)message image:(UIImage *)image;
@end
