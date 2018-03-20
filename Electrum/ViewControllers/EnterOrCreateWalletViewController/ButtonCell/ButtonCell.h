//
//  ButtonCell.h
//  Electrum
//
//  Created by Jasf on 19.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonCell : UITableViewCell
@property (copy, nonatomic) dispatch_block_t tappedHandler;
- (void)setTitle:(NSString *)title;
@end
