//
//  TitleView.m
//  Electrum
//
//  Created by Jasf on 28.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "TitleView.h"

@interface TitleView ()
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation TitleView

- (void)setText:(NSString *)text {
    _titleLabel.text = text;
}

- (void)setFont:(UIFont *)font {
    _titleLabel.font = font;
}

@end
