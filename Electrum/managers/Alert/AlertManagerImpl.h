//
//  AlertManagerImpl.h
//  Electrum
//
//  Created by Jasf on 23.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "AlertManager.h"
#import "ScreensManager.h"

@interface AlertManagerImpl : NSObject <AlertManager>
@property (strong, nonatomic) id<ScreensManager> screensManager;
@end
