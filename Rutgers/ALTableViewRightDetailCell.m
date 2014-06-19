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
    self.titleLabel.numberOfLines = 0;

    
    self.titleLabel.font = [UIFont systemFontOfSize:17];
    self.detailLabel.font = [UIFont systemFontOfSize:17];
    self.detailLabel.textColor = [UIColor lightGrayColor];
    self.detailLabel.textAlignment = NSTextAlignmentRight;
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.detailLabel];
 
}
-(void)initializeConstraints{
    
    UIEdgeInsets standardInsets = UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets, kLabelVerticalInsets, kLabelHorizontalInsets);
   
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.titleLabel autoPinEdgesToSuperviewEdgesWithInsets:standardInsets excludingEdge:ALEdgeRight];
   
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kLabelHorizontalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    [self.titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.detailLabel withOffset:kLabelHorizontalInsets];

    [self.detailLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.detailLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.detailLabel autoPinEdgesToSuperviewEdgesWithInsets:standardInsets excludingEdge:ALEdgeLeft];
    
}
-(void)makeConstraintChanges{
    
}
-(void)didLayoutSubviews{
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
}

@end
