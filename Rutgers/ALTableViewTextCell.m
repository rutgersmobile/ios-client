//
//  ALTableViewTextCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/4/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ALTableViewTextCell.h"
#import "RULabel.h"

@interface ALTableViewTextCell ()
@property (strong, nonatomic) IBOutlet UILabel *attributedTextLabel;
@property (nonatomic) NSLayoutConstraint *rightConstraint;
@end

@implementation ALTableViewTextCell

-(UILabel *)textLabel{
    return self.attributedTextLabel;
}

-(void)initializeSubviews{
    self.attributedTextLabel = [RULabel newAutoLayoutView];
    self.attributedTextLabel.numberOfLines = 0;
    [self.contentView addSubview:self.attributedTextLabel];
}

-(void)initializeConstraints{
    [self.attributedTextLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets, kLabelVerticalInsets, kLabelHorizontalInsets) excludingEdge:ALEdgeRight];
    self.rightConstraint = [self.attributedTextLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kLabelHorizontalInsets];
}

-(void)updateConstraints{
    [super updateConstraints];
    self.rightConstraint.constant = (self.accessoryType != UITableViewCellAccessoryNone) ? 0 : -kLabelHorizontalInsets;
}
@end
