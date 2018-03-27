//
//  TextViewCell.h
//  Electrum
//
//  Created by Jasf on 25.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *textView;
- (void)setTextViewText:(NSString *)text;
- (void)setEditingAllowed:(BOOL)allowed;
- (void)setStyleWithTransparentBackground:(BOOL)yes;
- (void)setAttributedString:(NSAttributedString *)attributedString;
- (CGFloat)desiredHeight:(CGFloat)width;
- (NSString *)enteredText;
@end
