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

    self.hoursLabel = [RULabel newAutoLayoutView];
    self.hoursLabel.numberOfLines = 0;
    
    [self.contentView addSubview:self.areaLabel];
    [self.contentView addSubview:self.hoursLabel];
    
}

-(void)updateFonts{
    self.areaLabel.font = [UIFont ruPreferredBoldFontForTextStyle:UIFontTextStyleFootnote];
    self.hoursLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleFootnote];
}

-(void)initializeConstraints{
    [@[self.areaLabel,self.hoursLabel] autoDistributeViewsAlongAxis:ALAxisHorizontal withFixedSpacing:15 alignment:NSLayoutFormatAlignAllTop];
    
    [self.areaLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    [self.areaLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.areaLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    
    [self.hoursLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
  
    [self.hoursLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.hoursLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
}


@end
