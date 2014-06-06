//
//  RURecCenterHoursHeaderTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURecCenterHoursHeaderTableViewCell.h"
@interface RURecCenterHoursHeaderTableViewCell ()
@end

@implementation RURecCenterHoursHeaderTableViewCell
-(void)makeSubviews{
    self.leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.leftButton.translatesAutoresizingMaskIntoConstraints = NO;
                       
    [self.leftButton setTitle:@"<=" forState:UIControlStateNormal];
    [self.leftButton addTarget:self action:@selector(goLeft:) forControlEvents:UIControlEventTouchUpInside];
    self.leftButton.titleLabel.font = [UIFont systemFontOfSize:20];

    
    self.rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.rightButton.translatesAutoresizingMaskIntoConstraints = NO;
   
    [self.rightButton setTitle:@"=>" forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(goRight:) forControlEvents:UIControlEventTouchUpInside];
    self.rightButton.titleLabel.font = [UIFont systemFontOfSize:20];
    
    self.dateLabel = [UILabel newAutoLayoutView];
    self.dateLabel.font = [UIFont systemFontOfSize:17];
    
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.leftButton];
    [self.contentView addSubview:self.rightButton];

}
-(void)makeConstraints{
    [self.leftButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];
    [self.leftButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    [self.rightButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kLabelHorizontalInsets];
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
