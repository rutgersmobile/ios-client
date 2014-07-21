//
//  NetworkContentStateLoadingView.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NetworkContentStateLoadingView.h"

@implementation NetworkContentStateLoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.label.text = @"Loading";
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
