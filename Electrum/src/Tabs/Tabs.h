//
//  Tabs.h
//  Horoscopes
//
//  Created by Jasf on 29.11.2017.
//  Copyright © 2017 Mail.Ru. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TabsAnimationsPreferences) {
    TabsAnimationFull,
    TabsAnimationFrameOnly,
    TabsAnimationNone
};

@interface Tabs : UIView
@property (nonatomic, nullable) NSArray *titles;
@property (copy, nonatomic, nonnull) void (^tabsItemViewSelected)(NSInteger previousIndex, NSInteger currentIndex);
- (void)setItemSelected:(NSInteger)itemIndex animated:(BOOL)animated;
- (void)setItemSelected:(NSInteger)itemIndex animation:(TabsAnimationsPreferences)animation;
- (void)setItemSelected:(NSInteger)itemIndex
              animation:(TabsAnimationsPreferences)animation
             withNotify:(BOOL)withNotify;
- (void)animateSelection:(Direction)direction patchCompleted:(CGFloat)completed;
@end
