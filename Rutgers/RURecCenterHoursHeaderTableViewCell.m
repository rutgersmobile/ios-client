//
//  RURecCenterHoursHeaderTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURecCenterHoursHeaderTableViewCell.h"
#import "PureLayout.h"
#import "UIFont+DynamicType.h"

@interface RURecCenterHoursHeaderTableViewCell ()
@end

@implementation RURecCenterHoursHeaderTableViewCell

-(void)initializeSubviews{
    self.leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.leftButton.translatesAutoresizingMaskIntoConstraints = NO;
                       
    [self.leftButton setImage:[UIImage imageNamed:@"arrow2"] forState:UIControlStateNormal];
    [self.leftButton addTarget:self action:@selector(goLeft:) forControlEvents:UIControlEventTouchUpInside];

    self.rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.rightButton.translatesAutoresizingMaskIntoConstraints = NO;
   
    [self.rightButton setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(goRight:) forControlEvents:UIControlEventTouchUpInside];
    
    self.dateLabel = [UILabel newAutoLayoutView];
    
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.leftButton];
    [self.contentView addSubview:self.rightButton];

}

-(void)updateFonts{
    self.dateLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleBody];
}

-(void)initializeConstraints{
    [self.leftButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.leftButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    [self.rightButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [self.rightButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    [self.dateLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.dateLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.dateLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets];
    [self.dateLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
}

- (IBAction)goLeft:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RecCenterHeaderLeft" object:nil];
}
- (IBAction)goRight:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RecCenterHeaderRight" object:nil];
}
@end
