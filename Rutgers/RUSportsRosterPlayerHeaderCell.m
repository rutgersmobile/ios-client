//
//  RUSportsRosterPlayerHeaderView.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSportsRosterPlayerHeaderCell.h"

@interface RUSportsRosterPlayerHeaderCell ()
@property (nonatomic) UIView *playerView;
@end

@implementation RUSportsRosterPlayerHeaderCell

-(void)initializeSubviews{
    
    UIView *playerView = [UIView newAutoLayoutView];
    self.playerView = playerView;
    [self addSubview:self.playerView];
    self.playerView.clipsToBounds = YES;
    
    self.titleLabel = [UILabel newAutoLayoutView];
    self.titleLabel.textColor = self.tintColor;
    [self addSubview:self.titleLabel];
    

    self.detailLabel = [UILabel newAutoLayoutView];
    self.detailLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.detailLabel];
    
    
    self.playerImageView = [UIImageView newAutoLayoutView];
    [self.playerView addSubview:self.playerImageView];

}

-(void)initializeConstraints{
    [self.playerView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(7, 7, 7, 7) excludingEdge:ALEdgeLeft];

    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:9];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:11];
    [self.titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.playerView withOffset:7];
    
    [self.detailLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:16];
    [self.detailLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:11];
    [self.detailLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.playerView withOffset:7];
    
    [self.playerImageView autoSetDimensionsToSize:CGSizeMake(76, 100)];
    [self.playerImageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:-10];
    [self.playerImageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
}



@end
