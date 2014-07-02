//
//  RUSOCSectionCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCSectionCell.h"

@interface RUSOCSectionCell ()
@property NSLayoutConstraint *descriptionConstraint;
@end

@implementation RUSOCSectionCell

-(void)makeSubviews{

    self.indexLabel = [UILabel newAutoLayoutView];
    self.professorLabel = [UILabel newAutoLayoutView];
    self.descriptionLabel = [UILabel newAutoLayoutView];
    self.dayLabel = [UILabel newAutoLayoutView];
    self.timeLabel = [UILabel newAutoLayoutView];
    self.locationLabel = [UILabel newAutoLayoutView];
    
    self.descriptionLabel.numberOfLines = 0;
    self.dayLabel.numberOfLines = 0;
    self.timeLabel.numberOfLines = 0;
    self.locationLabel.numberOfLines = 0;

    
    self.indexLabel.font = [UIFont boldSystemFontOfSize:14];
    self.professorLabel.font = [UIFont boldSystemFontOfSize:14];
    self.descriptionLabel.font = [UIFont systemFontOfSize:14];
    self.timeLabel.font = [UIFont systemFontOfSize:14];
    self.dayLabel.font = [UIFont boldSystemFontOfSize:14];
    self.locationLabel.font = [UIFont boldSystemFontOfSize:14];
    
    self.dayLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.contentView addSubview:self.indexLabel];
    [self.contentView addSubview:self.descriptionLabel];
    [self.contentView addSubview:self.professorLabel];
    [self.contentView addSubview:self.dayLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.locationLabel];
}

-(void)initializeConstraints{
    
    [self.indexLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.indexLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];

    [self.professorLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.professorLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kLabelHorizontalInsets];
    
    [self.descriptionLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.indexLabel withOffset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    [self.descriptionLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.professorLabel withOffset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kLabelHorizontalInsets];
    
    self.descriptionConstraint = [self.descriptionLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.dayLabel withOffset:kLabelVerticalInsets];
    
    [self.dayLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];
    [self.dayLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    [self.dayLabel autoSetDimension:ALDimensionWidth toSize:25];
    
    [self.timeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.dayLabel];
    [self.timeLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.dayLabel withOffset:kLabelHorizontalInsets];
    [self.timeLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    [self.timeLabel autoSetDimension:ALDimensionWidth toSize:105];
    
    [self.locationLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.dayLabel];
    [self.locationLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.timeLabel withOffset:kLabelHorizontalInsets];
    [self.locationLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
}

-(void)makeConstraintChanges{
    self.descriptionConstraint.constant = self.descriptionLabel.text.length ? -kLabelVerticalInsets : 0;
}

-(void)didLayoutSubviews{
    self.descriptionLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.descriptionLabel.frame);
}


@end
