//
//  RUReaderTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUReaderTableViewCell.h"
#import "iPadCheck.h"

@interface RUReaderTableViewCell ()
//@property NSLayoutConstraint *imageBottomConstraint;
@end

@implementation RUReaderTableViewCell

-(void)makeSubviews{
    
    self.titleLabel = [UILabel newAutoLayoutView];
    self.timeLabel = [UILabel newAutoLayoutView];
    self.imageDisplayView = [UIImageView newAutoLayoutView];
    
    self.imageDisplayView.clipsToBounds = YES;
    
    self.imageDisplayView.contentMode = UIViewContentModeScaleAspectFill;

    self.titleLabel.numberOfLines = 3;
    
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    
    self.timeLabel.font = [UIFont italicSystemFontOfSize:16];

    self.timeLabel.textColor = [UIColor scarletRedColor];
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.imageDisplayView];

}

-(void)initializeConstraints{
#define IMAGE_SIZE 68
    
    UIEdgeInsets standardInsets = UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets, kLabelVerticalInsets, 0);

    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];
    [self.titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.imageDisplayView withOffset:-kLabelHorizontalInsets];
    
    [self.imageDisplayView autoSetDimensionsToSize:CGSizeMake(IMAGE_SIZE, IMAGE_SIZE)];
    [self.imageDisplayView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [self.imageDisplayView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];

    [self.timeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.timeLabel autoPinEdgesToSuperviewEdgesWithInsets:standardInsets excludingEdge:ALEdgeTop];
    
    [self.timeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    [self.timeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.imageDisplayView withOffset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    
}
-(void)makeConstraintChanges{
    /*
    if (!self.timeLabel.text.length) {
        self.imageBottomConstraint.constant = 0;
    } else {
        self.imageBottomConstraint.constant = -IMAGE_BOTTOM_PADDING;
    }*/
}
-(void)didLayoutSubviews{
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
}
@end
