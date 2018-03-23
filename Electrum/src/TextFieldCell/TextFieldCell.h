//
//  TextFieldCell.h
//  Electrum
//
//  Created by Jasf on 22.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldCell : UITableViewCell
@property (readonly, nonatomic) UITextField *textField;
- (void)setAttributedString:(NSAttributedString *)string;
- (void)setString:(NSString *)string;
- (void)setRightLabelText:(NSString *)text;
- (NSString *)string;
@end
