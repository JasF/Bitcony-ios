//
//  ButtonsCell.h
//  Electrum
//
//  Created by Jasf on 26.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonsCell : UITableViewCell
@property (nonatomic, copy) void (^tapped)(NSInteger index);
- (void)setTitles:(NSArray *)titles;
@end
