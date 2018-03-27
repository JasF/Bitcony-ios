//
//  SharingObject.h
//  Horoscopes
//
//  Created by Jasf on 25.01.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SharingObject <UIActivityItemSource>
@property (strong, nonatomic) UIImage *image;
@end
