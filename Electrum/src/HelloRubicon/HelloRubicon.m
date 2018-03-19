//
//  HelloRubicon.m
//  Electrum
//
//  Created by Jasf on 19.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "HelloRubicon.h"

@implementation HelloRubicon
+ (instancetype)create {
    DDLogInfo(@"create");
    return nil;
}
- (id)init {
    if (self = [super init]) {
        DLog(@"HelloRubricon init possible from Python");
    }
    return self;
}

- (NSString *)description {
    return @"object allocated";
}
@end
