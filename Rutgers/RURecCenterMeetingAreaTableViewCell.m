//
//  RURecCenterMeetingAreaTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURecCenterMeetingAreaTableViewCell.h"

@implementation RURecCenterMeetingAreaTableViewCell
-(void)makeSubviews{
    self.areaLabel = [UILabel newAutoLayoutView];
    self.areaLabel.numberOfLines = 0;
    self.areaLabel.font = [UIFont boldSystemFontOfSize:14];

    self.timesLabel = [UILabel newAutoLayoutView];
    self.timesLabel.numberOfLines = 0;
    self.timesLabel.font = [UIFont systemFontOfSize:14];
    
    [self.contentView addSubview:self.areaLabel];
    [self.contentView addSubview:self.timesLabel];
}
-(void)makeConstraints{
    [@[self.areaLabel,self.timesLabel] autoDistributeViewsAlongAxis:ALAxisHorizontal withFixedSpacing:15 alignment:NSLayoutFormatAlignAllTop];
    
    [self.areaLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    [self.areaLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.areaLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    
    [self.timesLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
  
    [self.timesLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.timesLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
}
-(void)didLayoutSubviews{
    self.areaLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.areaLabel.frame);
    self.timesLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.timesLabel.frame);
}
@end
