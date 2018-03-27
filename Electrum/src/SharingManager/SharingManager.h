//
//  SharingManager.h
//  Horoscopes
//
//  Created by Jasf on 25.01.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SharingObject.h"

@interface SharingManager : NSObject

- (id)initWithSharingObject:(id<SharingObject>)sharingObject
             viewController:(UIViewController *)viewController
                 completion:(dispatch_block_t)completion;

- (void)start;

@end
