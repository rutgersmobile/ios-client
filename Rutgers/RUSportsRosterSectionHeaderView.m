//
//  RUSportsRosterSectionHeaderView.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSportsRosterSectionHeaderView.h"

@implementation RUSportsRosterSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.sectionHeaderLabel = [UILabel newAutoLayoutView];
        [self.contentView addSubview:self.sectionHeaderLabel];
      
        self.sectionHeaderLabel.font = [UIFont systemFontOfSize:18];
        [self.sectionHeaderLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:15.0];
        [self.sectionHeaderLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
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
