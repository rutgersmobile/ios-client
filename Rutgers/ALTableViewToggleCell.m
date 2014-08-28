//
//  ALTableViewToggleCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ALTableViewToggleCell.h"
#import "RULabel.h"


@interface ALTableViewToggleCell ()
@property (strong, nonatomic) IBOutlet UILabel *realTextLabel;
@end


@implementation ALTableViewToggleCell

-(UILabel *)textLabel{
    return self.realTextLabel;
}

-(void)initializeSubviews{
    self.realTextLabel = [RULabel newAutoLayoutView];
    self.realTextLabel.numberOfLines = 0;
    
    self.toggleSwitch = [[UISwitch alloc] initForAutoLayout];
    
    [self.contentView addSubview:self.realTextLabel];
    [self.contentView addSubview:self.toggleSwitch];
}

-(void)updateFonts{
    self.realTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

-(void)initializeConstraints{
    [self.realTextLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets, kLabelVerticalInsets, kLabelHorizontalInsets) excludingEdge:ALEdgeRight];
    [self.toggleSwitch autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kLabelHorizontalInsets];
    [self.toggleSwitch autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.realTextLabel withOffset:kLabelHorizontalInsets];
    [self.toggleSwitch autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
}



@end
