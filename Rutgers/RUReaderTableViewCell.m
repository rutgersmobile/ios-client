//
//  RUReaderTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUReaderTableViewCell.h"
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

    self.titleLabel.numberOfLines = 0;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.minimumScaleFactor = 0.7;
    
    self.titleLabel.font = [UIFont systemFontOfSize:24];
    
    self.timeLabel.font = [UIFont italicSystemFontOfSize:16];

    self.timeLabel.textColor = [UIColor scarletRedColor];
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.imageDisplayView];

}

-(void)initializeConstraints{
    UIEdgeInsets standardInsets = UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets, kLabelVerticalInsets, 0);

    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.titleLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.imageDisplayView withOffset:0 relation:NSLayoutRelationLessThanOrEqual];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:IMAGE_WIDTH+8];
    
    [self.imageDisplayView autoSetDimensionsToSize:CGSizeMake(IMAGE_WIDTH, IMAGE_HEIGHT)];
    [self.imageDisplayView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [self.imageDisplayView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];

//    self.imageBottomConstraint = [self.imageDisplayView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:IMAGE_BOTTOM_PADDING];

    [self.timeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.timeLabel autoPinEdgesToSuperviewEdgesWithInsets:standardInsets excludingEdge:ALEdgeTop];
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
