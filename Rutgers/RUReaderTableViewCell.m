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

@property (nonatomic) NSLayoutConstraint *timeTopConstraint;
@property (nonatomic) NSLayoutConstraint *titleRightConstraint;
@property (nonatomic) NSArray *descriptionTopConstraints;
@end

#define IMAGE_SIZE 68

@implementation RUReaderTableViewCell

-(void)initializeSubviews{
    self.imageDisplayView = [UIImageView newAutoLayoutView];
    self.imageDisplayView.clipsToBounds = YES;
    self.imageDisplayView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.titleLabel = [RULabel newAutoLayoutView];
    self.timeLabel = [UILabel newAutoLayoutView];
    self.descriptionLabel = [RULabel newAutoLayoutView];

    self.titleLabel.numberOfLines = 3;
    self.descriptionLabel.numberOfLines = 4;

    self.timeLabel.adjustsFontSizeToFitWidth = YES;
    self.timeLabel.minimumScaleFactor = 0.8;
    self.timeLabel.textColor = [UIColor scarletRedColor];
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.descriptionLabel];
    [self.contentView addSubview:self.imageDisplayView];
}

-(void)updateFonts{
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.timeLabel.font = [UIFont preferredItalicFontForTextStyle:UIFontTextStyleBody];
    self.descriptionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
}

-(void)initializeConstraints{
    
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];

    self.imageSizeConstraints = [self.imageDisplayView autoSetDimensionsToSize:CGSizeMake(IMAGE_SIZE, IMAGE_SIZE)];
    self.titleRightConstraint = [self.imageDisplayView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.titleLabel withOffset:kLabelHorizontalInsetsSmall];
    [self.imageDisplayView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.imageDisplayView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kLabelHorizontalInsets];
    [self.imageDisplayView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];

    [self.timeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.timeLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.titleLabel];
    [self.timeLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.titleLabel];
    self.timeTopConstraint = [self.timeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:kLabelVerticalInsetsSmall];
    
    NSLayoutConstraint *descriptionTopOne = [self.descriptionLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.timeLabel withOffset:kLabelVerticalInsetsSmall relation:NSLayoutRelationGreaterThanOrEqual];
    NSLayoutConstraint *descriptionTopTwo = [self.descriptionLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.imageDisplayView withOffset:kLabelVerticalInsetsSmall relation:NSLayoutRelationGreaterThanOrEqual];
    self.descriptionTopConstraints = @[descriptionTopOne,descriptionTopTwo];
    
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kLabelHorizontalInsets];
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets];
}

-(void)updateConstraints{
    [super updateConstraints];
    for (NSLayoutConstraint *constraint in self.imageSizeConstraints) { 
        constraint.constant = self.hasImage ? IMAGE_SIZE : 0;
    }
    
    self.timeTopConstraint.constant = self.timeLabel.text.length ? kLabelVerticalInsetsSmall : 0;
    self.titleRightConstraint.constant = self.hasImage ? kLabelHorizontalInsetsSmall : 0;
    
    for (NSLayoutConstraint *constraint in self.descriptionTopConstraints) {
        constraint.constant = self.descriptionLabel.text.length ? kLabelVerticalInsetsSmall : 0;
    }
}

@end
