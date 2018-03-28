//
//  SegmentedCell.h
//  Electrum
//
//  Created by Jasf on 28.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SegmentedCell : UITableViewCell
@property (nonatomic, copy) void (^selectedIndexChangedHandler)(NSInteger index);
- (void)setSelectedIndex:(NSInteger)index;
@end
