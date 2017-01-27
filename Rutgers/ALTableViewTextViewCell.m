//
//  ALTableViewTextViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 9/10/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ALTableViewTextViewCell.h"
#import "PureLayout.h"
#import "UIFont+DynamicType.h"

@implementation ALTableViewTextViewCell

-(void)initializeSubviews{
    self.textView = [UITextView newAutoLayoutView];
    [self.contentView addSubview:self.textView];
}

-(void)updateFonts{
    self.textView.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleBody];
}

-(void)initializeConstraints{
    [self.textView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets-5, kLabelVerticalInsets, kLabelHorizontalInsets-5)];
    [self.textView autoSetDimension:ALDimensionHeight toSize:150 relation:NSLayoutRelationGreaterThanOrEqual];
}

@end
