//
//  RUPredictionsTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPredictionsHeaderTableViewCell.h"

@interface RUPredictionsHeaderTableViewCell ()
@property (nonatomic) NSLayoutConstraint *directionConstraint;
@end


@implementation RUPredictionsHeaderTableViewCell

-(void)makeSubviews{
    self.titleLabel = [UILabel newAutoLayoutView];
    self.directionLabel = [UILabel newAutoLayoutView];
    self.timeLabel = [UILabel newAutoLayoutView];
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:19];
    self.directionLabel.font = [UIFont systemFontOfSize:16];
    self.timeLabel.font = [UIFont boldSystemFontOfSize:16];
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.directionLabel];
    [self.contentView addSubview:self.timeLabel];
}

-(void)initializeConstraints{
    UIEdgeInsets standardInsets = UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets, kLabelVerticalInsets, kLabelHorizontalInsets);
    
    [self.titleLabel autoPinEdgesToSuperviewEdgesWithInsets:standardInsets excludingEdge:ALEdgeBottom];
   
    self.directionConstraint = [self.directionLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:2];
  
    [self.directionLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];
    [self.directionLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kLabelHorizontalInsets];
    
    [self.directionLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.timeLabel withOffset:-2];
    
    [self.timeLabel autoPinEdgesToSuperviewEdgesWithInsets:standardInsets excludingEdge:ALEdgeTop];
}

-(void)makeConstraintChanges{
    self.directionConstraint.constant = self.directionLabel.text ? 2 : 0;
}

-(void)didLayoutSubviews{
}

@end
