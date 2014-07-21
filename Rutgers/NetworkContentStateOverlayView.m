//
//  NetworkContentStateOverlayView.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NetworkContentStateOverlayView.h"

@implementation NetworkContentStateOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [[UILabel alloc] initForAutoLayout];
        self.label.font = [UIFont systemFontOfSize:30];
        self.label.numberOfLines = 0;
        self.label.textAlignment = NSTextAlignmentCenter;
        
        self.label.textColor = [UIColor whiteColor];
        
        [self addSubview:self.label];
        [self.label autoCenterInSuperview];
        [self.label autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withMultiplier:0.8];
        [self.label autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self withMultiplier:0.8];
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
