//
//  UIView+LayoutSize.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "UIView+LayoutSize.h"

@implementation UIView (LayoutSize)
-(CGSize)layoutSizeFittingWidth:(CGFloat)width{
    // Get the actual height required for the cell
    UIView *contentView = self;
    
    
    CGRect bounds = self.bounds;
    
    if ([self isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell *)self;
        contentView = cell.contentView;
        if (cell.accessoryType != UITableViewCellAccessoryNone) width -= 34;
    }
    
    bounds.size.width = width;
    contentView.bounds = bounds;
    
    [contentView setNeedsLayout];
    [contentView layoutIfNeeded];
    
    CGSize fittingSize = [contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    fittingSize.height++;
    fittingSize.width++;
    
    return fittingSize;
}
@end
