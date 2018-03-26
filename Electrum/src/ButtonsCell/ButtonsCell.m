//
//  ButtonsCell.m
//  Electrum
//
//  Created by Jasf on 26.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "ButtonsCell.h"

static CGFloat const kCornerRadius = 2.f;

@interface ButtonsCell ()
@property (strong, nonatomic) IBOutlet UIButton *firstButton;
@property (strong, nonatomic) IBOutlet UIButton *secondButton;
@property (strong, nonatomic) IBOutlet UIButton *thirdButton;
@end

@implementation ButtonsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSArray *)buttons {
    return @[_firstButton, _secondButton, _thirdButton];;
}
- (void)setTitles:(NSArray *)titles {
    NSMutableArray *mutableTitles = [titles mutableCopy];
    for (UIButton *button in [self buttons]) {
        NSString *title = mutableTitles.firstObject;
        if (title.length) {
            button.hidden = NO;
            [mutableTitles removeObjectAtIndex:0];
            [button setTitle:title forState:UIControlStateNormal];
        }
        else {
            button.hidden = YES;
        }
        button.layer.cornerRadius = kCornerRadius;
    }
}

- (IBAction)tapped:(id)sender {
    NSInteger index = [[self buttons] indexOfObject:sender];
    NSCAssert(index != NSNotFound, @"Unknown button");
    if (index == NSNotFound) {
        return;
    }
    if (_tapped) {
        _tapped(index);
    }
}

@end
