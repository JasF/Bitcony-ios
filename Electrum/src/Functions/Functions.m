//
//  Functions.m
//  Electrum
//
//  Created by Jasf on 25.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "Functions.h"

void dispatch_python(dispatch_block_t _Nonnull block) {
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        block();
    });
}
