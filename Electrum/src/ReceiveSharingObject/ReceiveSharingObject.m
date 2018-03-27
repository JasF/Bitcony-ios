//
//  ReceiveSharingObject.m
//  Receives
//
//  Created by Jasf on 25.01.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "ReceiveSharingObject.h"

@interface ReceiveSharingObject ()
@property (strong, nonatomic) NSString *message;
@end

@implementation ReceiveSharingObject

@synthesize image = _image;

- (id)initWithMessage:(NSString *)message image:(UIImage *)image {
    NSCParameterAssert(message);
    NSCParameterAssert(image);
    if (self = [self init]) {
        _message = message;
        _image = image;
    }
    return self;
}

#pragma mark - UIActivityItemSource
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return _message;
}

- (nullable id)activityViewController:(UIActivityViewController *)activityViewController
                  itemForActivityType:(nullable UIActivityType)activityType {
    return _message;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController
              subjectForActivityType:(nullable UIActivityType)activityType {
    return _message;
}

@end
