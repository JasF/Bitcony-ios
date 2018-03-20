//
//  ScreensManagerImpl.h
//  Electrum
//
//  Created by Jasf on 19.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScreensManager.h"
#import "RunLoop.h"

@interface ScreensManagerImpl : NSObject <ScreensManager>
- (id)init NS_UNAVAILABLE;
+ (id)new NS_UNAVAILABLE;
- (id)initWithRunLoop:(RunLoop *)runLoop;
@end
