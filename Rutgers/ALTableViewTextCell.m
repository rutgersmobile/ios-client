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
@property (strong, nonatomic) IBOutlet UILabel *realTextLabel;
@property (nonatomic) NSLayoutConstraint *rightConstraint;
@end

@implementation ALTableViewTextCell

-(UILabel *)textLabel{
    return self.realTextLabel;
}

-(void)initializeSubviews{
    self.realTextLabel = [RULabel newAutoLayoutView];
    self.realTextLabel.numberOfLines = 0;
    [self.contentView addSubview:self.realTextLabel];
}

-(void)updateFonts{
    self.realTextLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleBody];
}

-(void)initializeConstraints{
    [self.realTextLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets, kLabelVerticalInsets, kLabelHorizontalInsets) excludingEdge:ALEdgeRight];
    self.rightConstraint = [self.realTextLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self];
    [self.realTextLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0 relation:NSLayoutRelationGreaterThanOrEqual];
}

-(void)updateConstraints{
    [super updateConstraints];
    self.rightConstraint.constant = (self.accessoryType != UITableViewCellAccessoryNone) ? -34 : -kLabelHorizontalInsets;
}
@end
