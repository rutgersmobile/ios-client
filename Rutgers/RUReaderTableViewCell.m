//
//  RUReaderTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUReaderTableViewCell.h"
#import "iPadCheck.h"
#import "RULabel.h"

@interface RUReaderTableViewCell ()
//@property NSLayoutConstraint *imageBottomConstraint;
@property (nonatomic) NSArray *imageSizeConstraints;
@property (nonatomic) NSArray *timeVerticalConstraints;
@end

#define IMAGE_SIZE 68

@implementation RUReaderTableViewCell

-(void)initializeSubviews{
    
    self.titleLabel = [RULabel newAutoLayoutView];
    self.timeLabel = [UILabel newAutoLayoutView];
    self.imageDisplayView = [UIImageView newAutoLayoutView];
    
    self.imageDisplayView.clipsToBounds = YES;
    
    self.imageDisplayView.contentMode = UIViewContentModeScaleAspectFill;

    self.titleLabel.numberOfLines = 3;
    
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    
    self.timeLabel.font = [UIFont italicSystemFontOfSize:16];
    self.timeLabel.adjustsFontSizeToFitWidth = YES;
    self.timeLabel.minimumScaleFactor = 0.8;
    self.timeLabel.textColor = [UIColor scarletRedColor];
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.imageDisplayView];
}

-(void)initializeConstraints{
    
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];
    [self.titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.imageDisplayView withOffset:-kLabelHorizontalInsets];

    self.imageSizeConstraints = [self.imageDisplayView autoSetDimensionsToSize:CGSizeMake(IMAGE_SIZE, IMAGE_SIZE)];
    [self.imageDisplayView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [self.imageDisplayView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [self.imageDisplayView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0 relation:NSLayoutRelationGreaterThanOrEqual];

    [self.timeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    [self.timeLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.titleLabel];
    [self.timeLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.titleLabel];
    [self.timeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    
    NSLayoutConstraint *timeConstraintTwo =  [self.timeLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets];
    self.timeVerticalConstraints = @[timeConstraintTwo];
}

-(void)updateConstraints{
    [super updateConstraints];
    for (NSLayoutConstraint *constraint in self.imageSizeConstraints) { 
        constraint.constant = self.hasImage ? IMAGE_SIZE : 0;
    }
    for (NSLayoutConstraint *constraint in self.timeVerticalConstraints) {
        constraint.constant = self.timeLabel.text.length ? -kLabelVerticalInsets : 0;
    }
}

@end
