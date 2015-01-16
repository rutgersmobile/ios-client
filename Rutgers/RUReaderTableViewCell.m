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
@property (nonatomic) NSLayoutConstraint *imageRightConstraint;
@property (nonatomic) NSLayoutConstraint *containerRightConstraint;
@property (nonatomic) NSLayoutConstraint *imageHeightConstraint;
@property (nonatomic) NSLayoutConstraint *timeTopConstraint;
@property (nonatomic) NSLayoutConstraint *descriptionTopConstraint;
@property (nonatomic) NSLayoutConstraint *descriptionBottomConstraint;
@property (nonatomic) UIView *containerView;
@end

#define IMAGE_SIZE round(62.0*(iPad() ? IPAD_SCALE : 1.0))

@implementation RUReaderTableViewCell

-(void)initializeSubviews{
    self.imageDisplayView = [UIImageView newAutoLayoutView];
    self.imageDisplayView.clipsToBounds = YES;
    self.imageDisplayView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageDisplayView.layer.cornerRadius = 2;
    
    self.containerView = [UIView newAutoLayoutView];
    
    self.titleLabel = [RULabel newAutoLayoutView];
    self.timeLabel = [UILabel newAutoLayoutView];
    self.descriptionLabel = [RULabel newAutoLayoutView];

    self.titleLabel.numberOfLines = 4;
    self.descriptionLabel.numberOfLines = 7;

    self.timeLabel.adjustsFontSizeToFitWidth = YES;
    self.timeLabel.minimumScaleFactor = 0.8;
    self.timeLabel.textColor = [UIColor darkGrayColor];
    
    [self.contentView addSubview:self.containerView];
    [self.contentView addSubview:self.imageDisplayView];

    [self.containerView addSubview:self.titleLabel];
    [self.containerView addSubview:self.descriptionLabel];
    [self.containerView addSubview:self.timeLabel];
}

-(void)updateFonts{
    self.titleLabel.font = [UIFont ruPreferredBoldFontForTextStyle:UIFontTextStyleSubheadline];// [UIFont ruPreferredFontForTextStyle:UIFontTextStyleHeadline];
    self.timeLabel.font = [UIFont ruPreferredItalicFontForTextStyle:UIFontTextStyleFootnote];//[UIFont ruPreferredItalicFontForTextStyle:UIFontTextStyleFootnote];
    self.descriptionLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleSubheadline];//[UIFont ruPreferredFontForTextStyle:UIFontTextStyleBody];
}

-(void)initializeConstraints{
    [self.containerView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets, kLabelVerticalInsets, kLabelHorizontalInsets) excludingEdge:ALEdgeRight];
    self.containerRightConstraint = [self.containerView autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.imageDisplayView withOffset:-kLabelHorizontalInsetsSmall];
    
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.titleLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    
    [self.timeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.timeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.timeLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.timeLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    self.timeTopConstraint = [self.timeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:kLabelVerticalInsetsSmall];

    self.descriptionTopConstraint = [self.descriptionLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.timeLabel withOffset:kLabelVerticalInsetsSmall];
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    self.descriptionBottomConstraint = [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    
    self.imageHeightConstraint = [self.imageDisplayView autoSetDimension:ALDimensionHeight toSize:IMAGE_SIZE];
    [self.imageDisplayView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionHeight ofView:self.imageDisplayView withMultiplier:1];
    
    [self.imageDisplayView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.imageDisplayView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    self.imageRightConstraint = [self.imageDisplayView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];

}

-(void)updateConstraints{
    [super updateConstraints];
    
    self.containerRightConstraint.constant = self.hasImage ? -kLabelHorizontalInsetsSmall : 0;
    self.imageHeightConstraint.constant = self.hasImage ? IMAGE_SIZE : 0;
    self.imageRightConstraint.constant = (self.accessoryType != UITableViewCellAccessoryNone) ? 0 : -kLabelHorizontalInsets;
    
    self.timeTopConstraint.constant = self.titleLabel.text.length ? kLabelVerticalInsetsSmall : 0;
    self.descriptionTopConstraint.constant = self.timeLabel.text.length ? kLabelVerticalInsetsSmall : 0;
    self.descriptionBottomConstraint.constant = self.descriptionLabel.text.length ? 0 : kLabelVerticalInsetsSmall;
}

@end
