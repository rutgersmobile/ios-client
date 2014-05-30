//
//  RUSOCCourseCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCCourseCell.h"

@implementation RUSOCCourseCell

-(void)makeSubviews{
    
    self.titleLabel = [UILabel newAutoLayoutView];
    self.creditsLabel = [UILabel newAutoLayoutView];
    self.sectionsLabel = [UILabel newAutoLayoutView];
    
    self.titleLabel.numberOfLines = 0;
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.creditsLabel.font = [UIFont systemFontOfSize:15];
    self.sectionsLabel.font = [UIFont systemFontOfSize:15];
    
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.creditsLabel];
    [self.contentView addSubview:self.sectionsLabel];
    
}
-(void)makeConstraints{
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kLabelHorizontalInsets];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:kLabelHorizontalInsets];
    
    [@[self.creditsLabel,self.sectionsLabel] autoDistributeViewsAlongAxis:ALAxisHorizontal withFixedSpacing:15 alignment:NSLayoutFormatAlignAllBottom];

    [self.creditsLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:4];
    [self.sectionsLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets];
    [self.sectionsLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:4];
    [self.creditsLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets];
}

-(void)didLayoutSubviews{
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
    
}
@end
