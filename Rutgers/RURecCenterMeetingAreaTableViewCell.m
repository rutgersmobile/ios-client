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

    self.timesLabel = [RULabel newAutoLayoutView];
    self.timesLabel.numberOfLines = 0;
    
    [self.contentView addSubview:self.areaLabel];
    [self.contentView addSubview:self.timesLabel];
    
}

-(void)updateFonts{
    self.areaLabel.font = [UIFont ruPreferredBoldFontForTextStyle:UIFontTextStyleFootnote];
    self.timesLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleFootnote];
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
