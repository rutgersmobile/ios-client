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
    self.areaLabel.font = [UIFont systemFontOfSize:17];

    self.dateLabel = [UILabel newAutoLayoutView];
    self.dateLabel.numberOfLines = 0;
    self.dateLabel.font = [UIFont systemFontOfSize:17];
    
    [self.contentView addSubview:self.areaLabel];
    [self.contentView addSubview:self.dateLabel];
}
-(void)makeConstraints{
    [@[self.areaLabel,self.dateLabel] autoDistributeViewsAlongAxis:ALAxisHorizontal withFixedSpacing:20 alignment:NSLayoutFormatAlignAllTop];
    
    [self.areaLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    [self.areaLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
   // [self.areaLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.contentView withOffset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    
    
    [self.dateLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
  
    [self.dateLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.dateLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets];
  //  [self.dateLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.contentView withOffset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    
}

@end
