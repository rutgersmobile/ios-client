//
//  RUPredictionsBodyTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/26/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPredictionsBodyTableViewCell.h"

@implementation RUPredictionsBodyTableViewCell

-(void)makeSubviews{
    self.minutesLabel = [UILabel newAutoLayoutView];
    self.descriptionLabel = [UILabel newAutoLayoutView];
    self.timeLabel = [UILabel newAutoLayoutView];
    
    self.minutesLabel.numberOfLines = 0;
    self.descriptionLabel.numberOfLines = 0;
    self.timeLabel.numberOfLines = 0;

    
    self.minutesLabel.font = [UIFont boldSystemFontOfSize:15];
    self.descriptionLabel.font = [UIFont systemFontOfSize:15];
    self.timeLabel.font = [UIFont boldSystemFontOfSize:15];
    
    self.minutesLabel.textAlignment = NSTextAlignmentRight;
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.contentView addSubview:self.minutesLabel];
    [self.contentView addSubview:self.descriptionLabel];
    [self.contentView addSubview:self.timeLabel];
}

-(void)initializeConstraints{
    
    [self.minutesLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];
    [self.minutesLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.minutesLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    [self.minutesLabel autoSetDimension:ALDimensionWidth toSize:25];
    
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.descriptionLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.minutesLabel];
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    [self.descriptionLabel autoSetDimension:ALDimensionWidth toSize:87];
    
    [self.timeLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.timeLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.descriptionLabel];
    [self.timeLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];

}

-(void)makeConstraintChanges{

}

-(void)didLayoutSubviews{

}


@end
