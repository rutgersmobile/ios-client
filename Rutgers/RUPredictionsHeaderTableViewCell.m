//
//  RUPredictionsTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPredictionsHeaderTableViewCell.h"
#import "RULabel.h"
#import <PureLayout.h>
#import "UIFont+DynamicType.h"

@interface RUPredictionsHeaderTableViewCell ()
@property (nonatomic) NSLayoutConstraint *directionConstraint;
@end


@implementation RUPredictionsHeaderTableViewCell

-(void)initializeSubviews{
    self.titleLabel = [RULabel newAutoLayoutView];
    self.directionLabel = [RULabel newAutoLayoutView];
    self.timeLabel = [RULabel newAutoLayoutView];
    
    self.titleLabel.numberOfLines = 0;
    self.directionLabel.numberOfLines = 0;
    self.timeLabel.numberOfLines = 0;
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.directionLabel];
    [self.contentView addSubview:self.timeLabel];
}

-(void)updateFonts{
    self.titleLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleHeadline];
    self.directionLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleBody];
    self.timeLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleBody];
}

-(void)initializeConstraints{
    UIEdgeInsets standardInsets = UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets, kLabelVerticalInsets, kLabelHorizontalInsets);
    
    [self.titleLabel autoPinEdgesToSuperviewEdgesWithInsets:standardInsets excludingEdge:ALEdgeBottom];
   
    self.directionConstraint = [self.directionLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:kLabelVerticalInsetsSmall];
  
    [self.directionLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];
    [self.directionLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kLabelHorizontalInsets];
    
    [self.timeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.directionLabel withOffset:kLabelVerticalInsetsSmall];
    [self.timeLabel autoPinEdgesToSuperviewEdgesWithInsets:standardInsets excludingEdge:ALEdgeTop];
}

-(void)updateConstraints{
    [super updateConstraints];
    self.directionConstraint.constant = self.directionLabel.text.length ? kLabelVerticalInsetsSmall : 0;
}



@end
