//
//  RUSOCSectionCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCSectionCell.h"
#import "RULabel.h"

@interface RUSOCSectionCell ()
@property (nonatomic) NSLayoutConstraint *descriptionConstraint;
@property (nonatomic) UIView *containerView;
@end

@implementation RUSOCSectionCell

-(void)initializeSubviews{

    self.indexLabel = [UILabel newAutoLayoutView];
    self.professorLabel = [RULabel newAutoLayoutView];
    self.descriptionLabel = [RULabel newAutoLayoutView];
    self.dayLabel = [RULabel newAutoLayoutView];
    self.timeLabel = [RULabel newAutoLayoutView];
    self.locationLabel = [RULabel newAutoLayoutView];
    self.containerView = [UIView newAutoLayoutView];
    
    ((RULabel *)self.dayLabel).ignoresPreferredLayoutWidth = YES;
    ((RULabel *)self.timeLabel).ignoresPreferredLayoutWidth = YES;
    ((RULabel *)self.locationLabel).ignoresPreferredLayoutWidth = YES;
    ((RULabel *)self.professorLabel).ignoresPreferredLayoutWidth = YES;
    
    self.descriptionLabel.numberOfLines = 0;
    self.dayLabel.numberOfLines = 0;
    self.timeLabel.numberOfLines = 0;
    self.locationLabel.numberOfLines = 0;
    self.professorLabel.numberOfLines = 0;
    
    self.dayLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.contentView addSubview:self.indexLabel];
    [self.contentView addSubview:self.descriptionLabel];
    [self.contentView addSubview:self.professorLabel];
    [self.contentView addSubview:self.containerView];
    
    [self.containerView addSubview:self.dayLabel];
    [self.containerView addSubview:self.timeLabel];
    [self.containerView addSubview:self.locationLabel];
}

-(void)updateFonts{
    self.indexLabel.font = [UIFont ruPreferredBoldFontForTextStyle:UIFontTextStyleSubheadline];
    self.professorLabel.font = [UIFont ruPreferredBoldFontForTextStyle:UIFontTextStyleSubheadline];
    self.descriptionLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.timeLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.dayLabel.font = [UIFont ruPreferredBoldFontForTextStyle:UIFontTextStyleSubheadline];
    self.locationLabel.font = [UIFont ruPreferredBoldFontForTextStyle:UIFontTextStyleSubheadline];
}

-(void)initializeConstraints{
    
    [self.indexLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.indexLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];

    [self.professorLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.professorLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kLabelHorizontalInsets];
    
    [self.descriptionLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.indexLabel withOffset:kLabelVerticalInsetsSmall relation:NSLayoutRelationGreaterThanOrEqual];
    [self.descriptionLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.professorLabel withOffset:kLabelVerticalInsetsSmall relation:NSLayoutRelationGreaterThanOrEqual];
    
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kLabelHorizontalInsets];
    
    self.descriptionConstraint = [self.descriptionLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.containerView withOffset:kLabelVerticalInsets];
    
    [self.containerView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    
    [self.dayLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [self.dayLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.dayLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0 relation:NSLayoutRelationGreaterThanOrEqual];
    
    [self.timeLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [self.timeLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.dayLabel withOffset:kLabelHorizontalInsets];
    [self.timeLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0 relation:NSLayoutRelationGreaterThanOrEqual];
    
    [self.locationLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [self.locationLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.timeLabel withOffset:kLabelHorizontalInsets];
    [self.locationLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0 relation:NSLayoutRelationGreaterThanOrEqual];
    [self.locationLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0 relation:NSLayoutRelationGreaterThanOrEqual];
}

-(void)updateConstraints{
    [super updateConstraints];
    self.descriptionConstraint.constant = self.descriptionLabel.text.length ? -kLabelVerticalInsetsSmall : 0;
}

@end
