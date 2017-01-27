//
//  RUSOCCourseCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCCourseCell.h"
#import "RULabel.h"
#import "PureLayout.h"
#import "UIFont+DynamicType.h"

@implementation RUSOCCourseCell

-(void)initializeSubviews{
    
    self.titleLabel = [RULabel newAutoLayoutView];
    self.creditsLabel = [UILabel newAutoLayoutView];
    self.sectionsLabel = [UILabel newAutoLayoutView];
    
    self.titleLabel.numberOfLines = 0;
    self.sectionsLabel.adjustsFontSizeToFitWidth = YES;
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.creditsLabel];
    [self.contentView addSubview:self.sectionsLabel];
}

-(void)updateFonts{
    self.titleLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleHeadline];
    self.creditsLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.sectionsLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleSubheadline];
}

-(void)initializeConstraints{
    UIEdgeInsets standardInsets = UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets, kLabelVerticalInsets, 0);

    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.titleLabel autoPinEdgesToSuperviewEdgesWithInsets:standardInsets excludingEdge:ALEdgeBottom];
    
    NSArray *constraints = [@[self.creditsLabel,self.sectionsLabel] autoDistributeViewsAlongAxis:ALAxisHorizontal alignedTo:ALAttributeBottom withFixedSpacing:15];
    
    for (NSLayoutConstraint *constraint in constraints) {
        if ([constraint.secondItem isEqual:self.contentView] && [constraint.firstItem isEqual:self.sectionsLabel]) {
            constraint.constant = 0;
            break;
        }
    }

    [self.creditsLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:4];
    [self.sectionsLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets];
    [self.sectionsLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:4];
    [self.creditsLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets];
}

@end
