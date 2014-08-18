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
    [super setBounds:bounds];
    
    if (self.numberOfLines != 1) {
        // If this is a multiline label, need to make sure
        // preferredMaxLayoutWidth always matches the frame width
        // (i.e. orientation change can mess this up)
        self.preferredMaxLayoutWidth = bounds.size.width;
    }
}

@end
