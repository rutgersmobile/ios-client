//
//  RUPredictionsExtraTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPredictionsBodyTableViewCell.h"

@implementation RUPredictionsBodyTableViewCell

-(void)makeSubviews{
    self.label = [UILabel newAutoLayoutView];
    self.label.numberOfLines = 0;
    self.label.font = [UIFont systemFontOfSize:16];
    self.contentView.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1];

    [self.contentView addSubview:self.label];
}
-(void)makeConstraints{
    [self.label autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets, kLabelVerticalInsets, kLabelHorizontalInsets)];
}

-(void)didLayoutSubviews{
    self.label.preferredMaxLayoutWidth = CGRectGetWidth(self.label.frame);
}

@end
