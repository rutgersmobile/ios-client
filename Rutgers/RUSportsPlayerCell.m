//
//  RUSportsPlayerCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSportsPlayerCell.h"

@interface RUSportsPlayerCell ()
@property UIView *playerView;
@end

@implementation RUSportsPlayerCell

-(void)makeSubviews{
    self.playerView = [UIView newAutoLayoutView];
    
    self.nameLabel = [UILabel newAutoLayoutView];
    self.nameLabel.font = [UIFont systemFontOfSize:18];
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    
    self.jerseyNumberLabel = [UILabel newAutoLayoutView];
    self.jerseyNumberLabel.font = [UIFont systemFontOfSize:18];
    
    self.initialsLabel = [UILabel newAutoLayoutView];
    self.initialsLabel.textAlignment = NSTextAlignmentCenter;
    self.playerImageView = [UIImageView newAutoLayoutView];
    self.playerImageView.contentMode = UIViewContentModeScaleAspectFill;

    [self.contentView addSubview:self.playerView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.jerseyNumberLabel];
    
    [self.playerView addSubview:self.initialsLabel];
    [self.playerView addSubview:self.playerImageView];
    self.playerView.clipsToBounds = YES;
    self.playerView.backgroundColor = [UIColor lightGrayColor];
}

-(void)initializeConstraints{
    [self.playerView autoSetDimensionsToSize:CGSizeMake(50, 50)];
    [self.playerView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];
    [self.playerView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:2];
    [self.playerView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:2 relation:NSLayoutRelationGreaterThanOrEqual];
    
    [self.initialsLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    [self.playerImageView autoSetDimensionsToSize:CGSizeMake(95, 125)];
    [self.playerImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.playerView withOffset:-18];
    [self.playerImageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    [self.nameLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.playerView withOffset:10];
    [self.nameLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];

    [self.jerseyNumberLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kLabelHorizontalInsets];
    [self.jerseyNumberLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.jerseyNumberLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.jerseyNumberLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.nameLabel withOffset:kLabelHorizontalInsets relation:NSLayoutRelationGreaterThanOrEqual];
}

-(void)didLayoutSubviews{

}
@end
