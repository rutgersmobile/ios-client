//
//  RUReaderTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUReaderTableViewCell.h"

@implementation RUReaderTableViewCell

-(void)makeSubviews{
    
    self.titleLabel = [UILabel newAutoLayoutView];
    self.detailLabel = [UILabel newAutoLayoutView];
    self.timeLabel = [UILabel newAutoLayoutView];
    
    self.detailLabel.numberOfLines = 0;
    self.titleLabel.numberOfLines = 0;
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.detailLabel.font = [UIFont systemFontOfSize:15];
    self.timeLabel.font = [UIFont boldSystemFontOfSize:16];

    self.timeLabel.textColor = self.tintColor;
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.timeLabel];

}
-(void)makeConstraints{
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kLabelHorizontalInsets];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    
    [self.detailLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.detailLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:2];
    [self.detailLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kLabelHorizontalInsets];
    [self.detailLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
    [self.detailLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    
    
    [self.timeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.timeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.detailLabel withOffset:2];
    [self.timeLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kLabelHorizontalInsets];
    [self.timeLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
    [self.timeLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets];

}

-(void)didLayoutSubviews{
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
    self.detailLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.detailLabel.frame);

}
@end
