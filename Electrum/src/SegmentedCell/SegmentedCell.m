//
//  SegmentedCell.m
//  Electrum
//
//  Created by Jasf on 28.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "SegmentedCell.h"

@interface SegmentedCell ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@end

@implementation SegmentedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSelectedIndex:(NSInteger)index {
    NSCAssert(index < _segmentedControl.numberOfSegments, @"index out of bounds");
    if (index >= _segmentedControl.numberOfSegments) {
        return;
    }
    [_segmentedControl setSelectedSegmentIndex:index];
}

- (IBAction)selectedIndexChanged:(UISegmentedControl *)sender {
    if (_selectedIndexChangedHandler) {
        _selectedIndexChangedHandler(sender.selectedSegmentIndex);
    }
}

@end
