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
-(void)initializeConstraints{
    UIEdgeInsets standardInsets = UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets, kLabelVerticalInsets, 0);

    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.titleLabel autoPinEdgesToSuperviewEdgesWithInsets:standardInsets excludingEdge:ALEdgeBottom];
    
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
