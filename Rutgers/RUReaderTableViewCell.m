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
@property (nonatomic) NSLayoutConstraint *imageHeightConstraint;

//@property (nonatomic) NSLayoutConstraint *timeTopConstraint;
@property (nonatomic) NSLayoutConstraint *titleTopConstraint;
@property (nonatomic) NSLayoutConstraint *descriptionTopConstraint;
@property (nonatomic) UIView *containerView;
@end

#define IMAGE_SIZE (60*(iPad() ? IPAD_SCALE : 1.0))

@implementation RUReaderTableViewCell

-(void)initializeSubviews{
    self.imageDisplayView = [UIImageView newAutoLayoutView];
    self.imageDisplayView.clipsToBounds = YES;
    self.imageDisplayView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageDisplayView.layer.cornerRadius = 2;
    self.imageDisplayView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
    self.imageDisplayView.layer.borderWidth = 1.0;
    
    self.containerView = [UIView newAutoLayoutView];
    
    self.titleLabel = [RULabel newAutoLayoutView];
    self.timeLabel = [UILabel newAutoLayoutView];
    self.descriptionLabel = [RULabel newAutoLayoutView];

    self.titleLabel.numberOfLines = 2;
    self.descriptionLabel.numberOfLines = 4;

    self.timeLabel.adjustsFontSizeToFitWidth = YES;
    self.timeLabel.minimumScaleFactor = 0.8;
    self.timeLabel.textColor = [UIColor darkGrayColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.descriptionLabel];
    
    [self.contentView addSubview:self.containerView];
    [self.containerView addSubview:self.timeLabel];
    [self.containerView addSubview:self.imageDisplayView];
}

-(void)updateFonts{
    self.titleLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleHeadline];
    self.timeLabel.font = [UIFont ruPreferredItalicFontForTextStyle:UIFontTextStyleFootnote];
    self.descriptionLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleBody];
}

-(void)initializeConstraints{
    [self.containerView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets, kLabelVerticalInsets, kLabelHorizontalInsets) excludingEdge:ALEdgeBottom];
    
    self.imageHeightConstraint = [self.imageDisplayView autoSetDimension:ALDimensionHeight toSize:IMAGE_SIZE];
    [self.imageDisplayView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionHeight ofView:self.imageDisplayView withMultiplier:16.0/9.0];
    
    [self.imageDisplayView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0 relation:NSLayoutRelationGreaterThanOrEqual];
    [self.imageDisplayView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0 relation:NSLayoutRelationGreaterThanOrEqual];
    [self.imageDisplayView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    
    [self.timeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.timeLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    //[self.timeLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.timeLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [self.timeLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0 relation:NSLayoutRelationGreaterThanOrEqual];
    
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    self.titleTopConstraint = [self.titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.containerView withOffset:kLabelVerticalInsetsSmall];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kLabelHorizontalInsets];
    
    self.descriptionTopConstraint = [self.descriptionLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:kLabelVerticalInsetsSmall relation:NSLayoutRelationGreaterThanOrEqual];
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kLabelHorizontalInsets];
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
}

-(void)updateConstraints{
    [super updateConstraints];
    
    self.imageHeightConstraint.constant = self.hasImage ? IMAGE_SIZE : 0;

    self.titleTopConstraint.constant = self.hasImage || self.timeLabel.text.length ? kLabelHorizontalInsetsSmall : 0;
    
    self.descriptionTopConstraint.constant = self.descriptionLabel.text.length ? kLabelVerticalInsetsSmall : 0;
}

@end
