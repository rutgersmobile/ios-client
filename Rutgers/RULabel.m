//
//  RULabel.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RULabel.h"

@implementation RULabel

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.numberOfLines != 1) {
        
        // If this is a multiline label, need to make sure
        // preferredMaxLayoutWidth always matches the frame width
        // (i.e. orientation change can mess this up)
        self.preferredMaxLayoutWidth = self.frame.size.width;
    }
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    
    // There's a bug where intrinsic content size
    // may be 1 point too short
        
    size.height += 1;
    
    return size;
}


@end
