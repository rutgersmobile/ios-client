//
//  RUReaderTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUReaderTableViewCell.h"
@interface RUReaderTableViewCell ()
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic) NSLayoutConstraint *topTimeConstraint;
@end

@implementation RUReaderTableViewCell
-(void)setTitle:(NSString *)title{
    self.titleLabel.text = title;
}
-(void)setDetail:(NSString *)detail{
    self.detailLabel.text = detail;
}
-(void)setTime:(NSString *)time{
    self.timeLabel.text = time;
  //  self.topTimeConstraint.constant = (time) ? 2 : 0;
}
-(void)makeSubviews{
    
    self.titleLabel = [UILabel newAutoLayoutView];
    self.detailLabel = [UILabel newAutoLayoutView];
    self.timeLabel = [UILabel newAutoLayoutView];
    
    self.detailLabel.numberOfLines = 0;
    self.titleLabel.numberOfLines = 0;
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.detailLabel.font = [UIFont systemFontOfSize:15];
    self.timeLabel.font = [UIFont boldSystemFontOfSize:16];

    self.timeLabel.textColor = self.tintColor;
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.timeLabel];

}
-(void)makeConstraints{
    UIEdgeInsets standardInsets = UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets, kLabelVerticalInsets, 0);
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.titleLabel autoPinEdgesToSuperviewEdgesWithInsets:standardInsets excludingEdge:ALEdgeBottom];
    
    [self.detailLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.detailLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:2];
    [self.detailLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kLabelHorizontalInsets];
    [self.detailLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
    [self.detailLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    
    [self.timeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    self.topTimeConstraint = [self.timeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.detailLabel withOffset:2];
    [self.timeLabel autoPinEdgesToSuperviewEdgesWithInsets:standardInsets excludingEdge:ALEdgeTop];
}

-(void)didLayoutSubviews{
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
    self.detailLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.detailLabel.frame);

}
@end
