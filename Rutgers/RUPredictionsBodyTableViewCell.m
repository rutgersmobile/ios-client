//
//  RUPredictionsBodyTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/26/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPredictionsBodyTableViewCell.h"
#import "RULabel.h"

@implementation RUPredictionsBodyTableViewCell

-(void)initializeSubviews{
    self.minutesLabel = [RULabel newAutoLayoutView];
    self.descriptionLabel = [RULabel newAutoLayoutView];
    self.timeLabel = [RULabel newAutoLayoutView];
    
    self.minutesLabel.numberOfLines = 0;
    self.descriptionLabel.numberOfLines = 0;
    self.timeLabel.numberOfLines = 0;
    
    self.minutesLabel.textAlignment = NSTextAlignmentRight;
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;

    ((RULabel *)self.minutesLabel).ignoresPreferredLayoutWidth = YES;
    ((RULabel *)self.descriptionLabel).ignoresPreferredLayoutWidth = YES;
    ((RULabel *)self.timeLabel).ignoresPreferredLayoutWidth = YES;
    
    [self.contentView addSubview:self.minutesLabel];
    [self.contentView addSubview:self.descriptionLabel];
    [self.contentView addSubview:self.timeLabel];
}

-(void)updateFonts{
    self.minutesLabel.font = [UIFont ruPreferredBoldFontForTextStyle:UIFontTextStyleBody];
    self.descriptionLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleBody];
    self.timeLabel.font = [UIFont ruPreferredBoldFontForTextStyle:UIFontTextStyleBody];
}

-(void)initializeConstraints{
    
    [self.minutesLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets*2];
    [self.minutesLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.minutesLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.descriptionLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.minutesLabel withOffset:kLabelHorizontalInsetsSmall];
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    
    [self.timeLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.timeLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.descriptionLabel withOffset:kLabelHorizontalInsetsSmall];
    [self.timeLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];

}

@end
