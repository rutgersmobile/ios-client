//
//  ALTableViewRightDetailCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ALTableViewRightDetailCell.h"

@interface ALTableViewRightDetailCell ()
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@end

@implementation ALTableViewRightDetailCell
-(UILabel *)textLabel{
    return self.titleLabel;
}
-(UILabel *)detailTextLabel{
    return self.detailLabel;
}

-(void)makeSubviews{
    self.titleLabel = [UILabel newAutoLayoutView];
    self.detailLabel = [UILabel newAutoLayoutView];
    
    self.titleLabel.font = [UIFont systemFontOfSize:17];
    self.detailLabel.font = [UIFont systemFontOfSize:17];
    self.detailLabel.textColor = [UIColor lightGrayColor];
    self.detailLabel.textAlignment = NSTextAlignmentRight;
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.detailLabel];
}
-(void)makeConstraints{
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kLabelHorizontalInsets];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets];
   
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:kLabelHorizontalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    [self.titleLabel autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:self.detailLabel withOffset:kLabelHorizontalInsets];

    [self.detailLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.detailLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.detailLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.detailLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:kLabelHorizontalInsets];
    [self.detailLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets];
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
