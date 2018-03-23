//
//  Managers.h
//  Electrum
//
//  Created by Jasf on 19.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScreensManager.h"
#import "AlertManager.h"

@interface Managers : NSObject
+ (instancetype)shared;
- (id<ScreensManager>)screensManager;
- (id<AlertManager>)alertManager;
- (NSString *)documentsDirectory;
@end
