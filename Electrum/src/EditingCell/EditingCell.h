//
//  EditingCell.h
//  Electrum
//
//  Created by Jasf on 26.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *textField;
- (void)setImage:(UIImage *)image
           title:(NSString *)title
     editingText:(NSString *)editingText
bottomDelimeterVisible:(BOOL)bottomDelimeterVisible;
- (void)setRightText:(NSString *)text;
@end
