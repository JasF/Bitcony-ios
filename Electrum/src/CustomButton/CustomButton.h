//
//  CustomButton.h
//  Electrum
//
//  Created by Jasf on 25.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomButton : UIButton
- (void)setNormalBackground:(BOOL)animated;
- (void)setHighlightedBackground:(BOOL)animated;
- (void)setBackgroundColor:(UIColor *)backgroundColor animated:(BOOL)animated;
@end
