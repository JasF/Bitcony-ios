//
//  ImageCell.m
//  Electrum
//
//  Created by Jasf on 26.03.2018.
//  Copyright © 2018 Freedom. All rights reserved.
//

#import "ImageCell.h"

static CGFloat const kSideMargin = 60.f;

@interface ImageCell ()
@property (strong, nonatomic) IBOutlet UIImageView *mainImageView;
@end

@implementation ImageCell

+ (CGFloat)sideMargin {
    return kSideMargin;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMainImage:(UIImage *)image {
    _mainImageView.image = image;
}

@end
