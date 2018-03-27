//
//  SharingManager.m
//  Horoscopes
//
//  Created by Jasf on 25.01.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "SharingManager.h"

@interface SharingManager ()
@property (strong, nonatomic) id<SharingObject> sharingObject;
@property (strong, nonatomic) dispatch_block_t completion;
@property (strong, nonatomic) UIViewController *sourceViewController;
@property (strong, nonatomic) UIActivityViewController *activityViewController;
@end

@implementation SharingManager

#pragma mark - Initialization
- (id)initWithSharingObject:(id<SharingObject>)sharingObject
             viewController:(UIViewController *)viewController
                 completion:(dispatch_block_t)completion {
    NSCParameterAssert(sharingObject);
    NSCParameterAssert(viewController);
    if (self = [self init]) {
        _sharingObject = sharingObject;
        _sourceViewController = viewController;
        _completion = completion;
    }
    return self;
}

#pragma mark - Public Methods
- (void)start {
    _activityViewController = [[UIActivityViewController alloc] initWithActivityItems:[self activityItems]
                                                                applicationActivities:nil];
    [_sourceViewController presentViewController:_activityViewController animated:YES completion:nil];
    
    
    @weakify(self);
    void (^completionHandler)(NSString *activityType, BOOL completed, NSArray *returnedItems,
                              NSError *activityError) =
    ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        @strongify(self);
        if (self.completion) {
            self.completion();
        }
    };
    [_activityViewController setCompletionWithItemsHandler:completionHandler];
}

#pragma mark - Private Methods
- (NSArray *)activityItems {
    NSMutableArray *array = [NSMutableArray new];
    [array addObject:_sharingObject];
    if (_sharingObject.image) {
        [array addObject:_sharingObject.image];
    }
    return [array copy];
}

@end
