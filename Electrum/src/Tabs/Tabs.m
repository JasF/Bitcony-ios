//
//  Tabs.m
//  Horoscopes
//
//  Created by Jasf on 29.11.2017.
//  Copyright © 2017 Mail.Ru. All rights reserved.
//

#import "Tabs.h"
#import "TabsItemView.h"
#import "UIView+TKGeometry.h"

static NSInteger const kTabsCount = 3;
static CGFloat const kAnimationDuration = 0.25f;

@interface Tabs ()
@property (strong, nonatomic) NSMutableArray *itemViews;
@property (assign, nonatomic) NSInteger leftItemIndex;
@property (assign, nonatomic) NSInteger selectedIndex;
@property (assign, nonatomic) CGFloat xDelta;
@end

@implementation Tabs

#pragma mark - Initialization
- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - Public Methods
- (void)setTitles:(NSArray *)titles {
    _titles = titles;
    if (_selectedIndex >= _titles.count) {
        _selectedIndex = 0;
    }
    for (TabsItemView *itemView in _itemViews) {
        [itemView removeFromSuperview];
    }
    NSMutableArray *views = [NSMutableArray new];
    @weakify(self);
    for (NSString *title in _titles) {
        TabsItemView *itemView = (TabsItemView *)[[NSBundle mainBundle] loadNibNamed:@"TabsItemView" owner:nil options:nil].firstObject;
        @weakify(itemView);
        itemView.touchesBlock = ^(TabItemViewTouchState state) {
            @strongify(self);
            @strongify(itemView);
            [self touchChangedForItemView:itemView withState:state];
        };
        [itemView setTitle:title];
        [self addSubview:itemView];
        [views addObject:itemView];
    }
    _itemViews = [views copy];
    [self setNeedsLayout];
}

- (void)cancelItemSemiSelection:(NSInteger)itemIndex animated:(BOOL)animated {
    NSCAssert(itemIndex < _itemViews.count, @"itemIndex out of bounds. index: %@; items: %@", @(itemIndex), _itemViews);
    TabsItemView *itemView = _itemViews[itemIndex];
    TabsItemView *selectedItem = self.selectedItem;
    
    dispatch_block_t block = ^{
        if (![itemView isEqual:selectedItem]) {
            [itemView setItemHighlighted:NO syncLabelColor:YES];
        }
        [selectedItem setItemHighlighted:YES syncLabelColor:YES];
    };
    if (animated) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            block();
        }];
    }
    else {
        block();
    }
}

- (void)setItemSemiSelected:(NSInteger)itemIndex animated:(BOOL)animated {
    NSCAssert(itemIndex < _itemViews.count, @"itemIndex out of bounds. index: %@; items: %@", @(itemIndex), _itemViews);
    TabsItemView *candidateItem = _itemViews[itemIndex];
    TabsItemView *selectedItem = self.selectedItem;
    
    dispatch_block_t block = ^{
        if ([candidateItem isEqual:selectedItem]) {
            [candidateItem setOverSelection];
        }
        else {
            [candidateItem setItemSemiHighlighted];
            [selectedItem setItemSemiHighlighted];
        }
    };
    if (animated) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            block();
        }];
    }
    else {
        block();
    }
}

- (void)setItemSelected:(NSInteger)itemIndex animated:(BOOL)animated {
    [self setItemSelected:itemIndex animation:(animated) ? TabsAnimationFull : TabsAnimationNone];
}


- (void)setItemSelected:(NSInteger)itemIndex animation:(TabsAnimationsPreferences)animation {
    [self setItemSelected:itemIndex animation:animation withNotify:(animation != TabsAnimationFrameOnly)];
}

- (void)setItemSelected:(NSInteger)itemIndex animation:(TabsAnimationsPreferences)animation withNotify:(BOOL)withNotify {
    NSCAssert(itemIndex < _itemViews.count, @"itemIndex out of bounds. index: %@; items: %@", @(itemIndex), _itemViews);
    TabsItemView *itemView = _itemViews[itemIndex];
    dispatch_block_t unhighlightBlock = ^{
        [self.itemViews enumerateObjectsUsingBlock:^(TabsItemView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![itemView isEqual:obj]) {
                [obj setItemHighlighted:NO];
            }
        }];
    };
    dispatch_block_t highlightBlock = ^{
        [itemView setItemHighlighted:YES];
    };
    
    dispatch_block_t highlightingBlock = ^{
        unhighlightBlock();
        highlightBlock();
    };
    
    _xDelta = 0.f;
    NSInteger maximumLeftIndex = self.itemViews.count - self.tabsCount;
    _leftItemIndex = itemIndex - 1;
    if (_leftItemIndex < 0) {
        _leftItemIndex = 0;
    }
    if (_leftItemIndex > maximumLeftIndex) {
        _leftItemIndex = maximumLeftIndex;
    }
    if (animation == TabsAnimationNone) {
        highlightingBlock();
    }
    else {
        if (animation == TabsAnimationFrameOnly) {
            highlightingBlock();
        }
        [UIView animateWithDuration:kAnimationDuration animations:^{
            if (animation == TabsAnimationFull) {
                highlightingBlock();
            }
            [self updateLayout];
        }];
    }
    [self setSelectedIndex:itemIndex withNotify:withNotify];
}

#pragma mark - Layouting
- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateLayout];
}

- (void)updateLayout {
    CGFloat itemWidth = self.width/self.tabsCount;
    CGFloat xOffset = -itemWidth*self.leftItemIndex + _xDelta;
    for (TabsItemView *view in _itemViews) {
        view.frame = CGRectMake(xOffset, 0.f, itemWidth, self.height);
        xOffset += view.width;
    }
}

#pragma mark - Private Methods
- (NSInteger)tabsCount {
    return kTabsCount;
}

- (void)touchChangedForItemView:(TabsItemView *)itemView withState:(TabItemViewTouchState)state {
    NSInteger index = [_itemViews indexOfObject:itemView];
    NSCAssert(index != NSNotFound, @"unknown object");
    switch (state) {
        case TabItemViewTouchBegin:
            [self setItemSemiSelected:index animated:YES];
            break;
        case TabItemViewTouchCancelled:
            [self cancelItemSemiSelection:index animated:YES];
            break;
        case TabItemViewTouchFinished:
            [self setItemSelected:index animated:YES];
            break;
    }
}

- (TabsItemView *)selectedItem {
    NSCAssert(_selectedIndex < _itemViews.count, @"index out of bounds");
    return _itemViews[_selectedIndex];
}

- (TabsItemView *)previousItem {
    NSCAssert(_selectedIndex < _itemViews.count, @"index out of bounds");
    return (_selectedIndex) ? _itemViews[_selectedIndex-1] : nil;
}

- (TabsItemView *)nextItem {
    NSCAssert(_selectedIndex < _itemViews.count, @"index out of bounds");
    return (_selectedIndex < _itemViews.count - 1) ? _itemViews[_selectedIndex+1] : nil;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex withNotify:(BOOL)withNotify {
    NSInteger previous = _selectedIndex;
    _selectedIndex = selectedIndex;
    if (withNotify && previous != _selectedIndex && _tabsItemViewSelected) {
        _tabsItemViewSelected(previous, _selectedIndex);
    }
}

#pragma mark - Public Methods
- (void)animateSelection:(Direction)direction patchCompleted:(CGFloat)completed {
    TabsItemView *currentItem = [self selectedItem];
    TabsItemView *nextItem = (direction == DirectionForwardToLeft) ? [self nextItem] : [self previousItem];
    if (!currentItem || !nextItem) {
        return;
    }
    for (TabsItemView *itemView in @[currentItem, nextItem]) {
        [itemView animateSelection:direction patchCompleted:completed selected:[currentItem isEqual:itemView]];
    }
    CGFloat itemWidth = self.width/self.tabsCount;
    _xDelta = (direction == DirectionForwardToLeft) ? -itemWidth*completed : itemWidth*completed;
    if (direction == DirectionForwardToLeft) {
        if (!_selectedIndex || _selectedIndex == _titles.count - 1 || _selectedIndex == _titles.count - 2) {
            _xDelta = 0;
        }
    }
    else {
        if (_selectedIndex == 1 || _selectedIndex == _titles.count - 1) {
            _xDelta = 0;
        }
    }
    [self setNeedsLayout];
}

@end
