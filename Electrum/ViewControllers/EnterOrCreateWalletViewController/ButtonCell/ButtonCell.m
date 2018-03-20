//
//  ButtonCell.m
//  Electrum
//
//  Created by Jasf on 19.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "ButtonCell.h"

@interface ButtonCell ()
@property (strong, nonatomic) IBOutlet UIButton *button;
@end

@implementation ButtonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Public Methods
- (void)setTitle:(NSString *)title {
    [_button setTitle:title forState:UIControlStateNormal];
}

#pragma mark - Private Methods
- (IBAction)tapped:(id)sender {
    if (_tappedHandler) {
        _tappedHandler();
    }
}

@end
