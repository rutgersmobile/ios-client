//
//  RULabel.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RULabel.h"

@implementation RULabel
-(void)setBounds:(CGRect)bounds{
    CGRect oldBounds = self.bounds;
    [super setBounds:bounds];
    
    // If this is a multiline label, need to make sure
    // preferredMaxLayoutWidth always matches the frame width
    // (i.e. orientation change can mess this up)
    if (CGRectGetWidth(oldBounds) != CGRectGetWidth(bounds)) self.preferredMaxLayoutWidth = bounds.size.width;
}

-(CGSize)intrinsicContentSize{
    if (!self.ignoresPreferredLayoutWidth) return [super intrinsicContentSize];
    return [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
}

@end
