//
//  UIView+LayoutSize.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "UIView+LayoutSize.h"

@implementation UIView (LayoutSize)
-(CGSize)layoutSizeFittingSize:(CGSize)size{
  //  [self setNeedsUpdateConstraints];
  //  [self updateConstraintsIfNeeded];
    
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;

    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    // Get the actual height required for the cell
    UIView *contentView = [self respondsToSelector:@selector(contentView)] ? [self performSelector:@selector(contentView)] : self;
    CGSize layoutSize = [contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    // Add an extra point to the height to account for internal rounding errors that are occasionally observed in
    // the Auto Layout engine, which cause the returned height to be slightly too small in some cases.
    layoutSize.height += 1;
    layoutSize.width += 1;

    return layoutSize;
}
@end
