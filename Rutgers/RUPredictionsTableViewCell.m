//
//  RUPredictionTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/24/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPredictionsTableViewCell.h"
@interface RUPredictionsTableViewCell ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *directionLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic) NSLayoutConstraint *topDirectionConstraint;
@end

@implementation RUPredictionsTableViewCell
-(void)setTitle:(NSString *)title{
    self.titleLabel.text = title;
}
-(void)setDirection:(NSString *)direction{
    self.directionLabel.text = direction;
   // self.topDirectionConstraint.constant = (direction) ? 4 : 0;
 //   [self.directionLabel setNeedsUpdateConstraints];
}
-(void)setTime:(NSString *)time{
    self.timeLabel.text = time;
}
-(void)setTimeColor:(UIColor *)color{
    self.timeLabel.textColor = color;
}
-(void)makeSubviews{
   
    self.titleLabel = [UILabel newAutoLayoutView];
    self.directionLabel = [UILabel newAutoLayoutView];
    self.timeLabel = [UILabel newAutoLayoutView];
    
    self.titleLabel.numberOfLines = 0;
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:19];
    self.directionLabel.font = [UIFont systemFontOfSize:16];
    self.timeLabel.font = [UIFont boldSystemFontOfSize:17];

    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.directionLabel];
    [self.contentView addSubview:self.timeLabel];
    
}
-(void)makeConstraints{
    UIEdgeInsets insets = UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets, kLabelVerticalInsets, kLabelHorizontalInsets);
    
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.titleLabel autoPinEdgesToSuperviewEdgesWithInsets:insets excludingEdge:ALEdgeBottom];
    
    self.topDirectionConstraint = [self.directionLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:4];
    [self.directionLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kLabelHorizontalInsets];
    [self.directionLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:kLabelHorizontalInsets];

    [self.timeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.directionLabel withOffset:4];
    [self.timeLabel autoPinEdgesToSuperviewEdgesWithInsets:insets excludingEdge:ALEdgeTop];
}

-(void)didLayoutSubviews{
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
