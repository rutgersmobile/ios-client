//
//  ALTableViewRightDetailCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ALTableViewRightDetailCell.h"
#import "RULabel.h"
#import "PureLayout.h"
#import "UIFont+DynamicType.h"

@interface ALTableViewRightDetailCell ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;

@property (nonatomic) NSLayoutConstraint *textToDetailTextConstraint;
@property (nonatomic) NSLayoutConstraint *rightConstraint;
@end

@implementation ALTableViewRightDetailCell
-(UILabel *)textLabel{
    return self.titleLabel;
}

-(UILabel *)detailTextLabel{
    return self.detailLabel;
}

-(void)initializeSubviews{
 
    self.titleLabel = [RULabel newAutoLayoutView];
    self.titleLabel.numberOfLines = 0;
   
    self.detailLabel = [UILabel newAutoLayoutView];
    self.detailLabel.textColor = [UIColor grayColor];
    self.detailLabel.textAlignment = NSTextAlignmentRight;
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.detailLabel];
 
}

-(void)updateFonts{
    self.titleLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleBody];
    self.detailLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleBody];
}

-(void)initializeConstraints{
    
    UIEdgeInsets standardInsets = UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets, kLabelVerticalInsets, kLabelHorizontalInsets);
   
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.titleLabel autoPinEdgesToSuperviewEdgesWithInsets:standardInsets excludingEdge:ALEdgeRight];
   
    self.textToDetailTextConstraint = [self.detailLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.titleLabel withOffset:kLabelHorizontalInsets];

    [self.detailLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.detailLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.detailLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.detailLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    self.rightConstraint = [self.detailLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kLabelHorizontalInsets];

}

-(void)updateConstraints{
    [super updateConstraints];
    self.textToDetailTextConstraint.constant = self.detailLabel.text.length ? kLabelHorizontalInsets : 0;
    self.titleLabel.numberOfLines = self.detailLabel.text.length ? 1 : 0;
    self.rightConstraint.constant = (self.accessoryType != UITableViewCellAccessoryNone) ? 0 : -kLabelHorizontalInsets;
}


@end
