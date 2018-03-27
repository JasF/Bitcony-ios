//
//  ButtonCell.h
//  Electrum
//
//  Created by Jasf on 19.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@interface ButtonCell : UITableViewCell
@property (strong, nonatomic) IBOutlet CustomButton *button;
@property (copy, nonatomic) dispatch_block_t tappedHandler;
- (void)setTitle:(NSString *)title;
- (void)setButtonImage:(UIImage *)image;
- (void)setDelimeterVisible:(BOOL)delimeterVisible;
- (void)setButtonEnabled:(BOOL)enabled;
@end
