//
//  RUSportsPlayerCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSportsPlayerCell.h"
#import <UIKit+AFNetworking.h>
#import "RULabel.h"
#import "RUImageResponseSerializer.h"
#import "RUSportsPlayerCell_Private.h"

@implementation RUSportsPlayerCell

-(void)initializeSubviews{
    self.playerView = [UIView newAutoLayoutView];
    
    self.nameLabel = [UILabel newAutoLayoutView];
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    
    self.jerseyNumberLabel = [UILabel newAutoLayoutView];
    
    self.positionLabel = [RULabel newAutoLayoutView];
    self.positionLabel.numberOfLines = 2;
    
    
    self.initialsLabel = [UILabel newAutoLayoutView];
    self.initialsLabel.textAlignment = NSTextAlignmentCenter;
    self.playerImageView = [UIImageView newAutoLayoutView];
    self.playerImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.contentView addSubview:self.playerView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.positionLabel];
    [self.contentView addSubview:self.jerseyNumberLabel];
    
    [self.playerView addSubview:self.initialsLabel];
    [self.playerView addSubview:self.playerImageView];
    
    self.playerView.clipsToBounds = YES;
    self.playerView.backgroundColor = [UIColor lightGrayColor];
}

-(void)updateFonts{
    self.nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.jerseyNumberLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
}

-(void)initializeConstraints{
    [self.playerView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];

    [self.playerView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];

    [self.initialsLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];

    [self.playerImageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    [self.nameLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.playerView withOffset:kLabelHorizontalInsetsSmall];
    [self.nameLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    
    [self.positionLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.playerView withOffset:kLabelHorizontalInsetsSmall];
    [self.positionLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.jerseyNumberLabel withOffset:-kLabelHorizontalInsetsSmall];
    [self.positionLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.nameLabel withOffset:kLabelVerticalInsetsSmall];
    [self.positionLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    
    [self.jerseyNumberLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kLabelHorizontalInsets];
    [self.jerseyNumberLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.jerseyNumberLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.jerseyNumberLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.nameLabel withOffset:kLabelHorizontalInsetsSmall];
    
}

@end
