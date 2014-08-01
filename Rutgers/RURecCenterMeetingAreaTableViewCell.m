//
//  RURecCenterMeetingAreaTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURecCenterMeetingAreaTableViewCell.h"
#import "RULabel.h"

@implementation RURecCenterMeetingAreaTableViewCell
-(void)initializeSubviews{
    self.areaLabel = [RULabel newAutoLayoutView];
    self.areaLabel.numberOfLines = 0;
    self.areaLabel.font = [UIFont boldSystemFontOfSize:14];

    self.timesLabel = [UILabel newAutoLayoutView];
    self.timesLabel.numberOfLines = 0;
    self.timesLabel.font = [UIFont systemFontOfSize:14];
    
    [self.contentView addSubview:self.areaLabel];
    [self.contentView addSubview:self.timesLabel];
    
}

-(void)initializeConstraints{
    [@[self.areaLabel,self.timesLabel] autoDistributeViewsAlongAxis:ALAxisHorizontal withFixedSpacing:15 alignment:NSLayoutFormatAlignAllTop];
    
    [self.areaLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    [self.areaLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.areaLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    
    [self.timesLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
  
    [self.timesLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.timesLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
}


@end
