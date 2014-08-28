//
//  ALTableViewTextViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ALTableViewTextFieldCell.h"

@interface ALTableViewTextFieldCell()
@property UILabel *realTextLabel;
@end

@implementation ALTableViewTextFieldCell

-(UILabel *)textLabel{
    return self.realTextLabel;
}

-(void)initializeSubviews{
    self.realTextLabel = [UILabel newAutoLayoutView];
    self.textField = [UITextField newAutoLayoutView];
    self.textField.enablesReturnKeyAutomatically = YES;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;

    [self.contentView addSubview:self.realTextLabel];
    [self.contentView addSubview:self.textField];
}

-(void)updateFonts{
    self.realTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

-(void)initializeConstraints{
    [self.realTextLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.realTextLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets, kLabelVerticalInsets, kLabelHorizontalInsets) excludingEdge:ALEdgeRight];
    [self.textField autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets, kLabelVerticalInsets, kLabelHorizontalInsets) excludingEdge:ALEdgeLeft];
    [self.realTextLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.textField withOffset:-kLabelHorizontalInsets];
}

@end
