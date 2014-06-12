//
//  RUMenuSectionHeaderView.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/5/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMenuSectionHeaderView.h"

@implementation RUMenuSectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor grey3Color];
        self.opaque = YES;
        self.contentView.opaque = YES;

        self.sectionTitleLabel = [UILabel newAutoLayoutView];
        [self.contentView addSubview:self.sectionTitleLabel];

        self.sectionTitleLabel.font = [UIFont systemFontOfSize:14];
        self.sectionTitleLabel.textColor = [UIColor colorWithRed:147/255.0 green:166/255.0 blue:176/255.0 alpha:1];
        
        [self.sectionTitleLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.sectionTitleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16.0];
        [self.sectionTitleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16.0];

        self.layer.borderColor = [UIColor grey4Color].CGColor;
        self.layer.borderWidth = 0.5;
        self.clipsToBounds = YES;
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
