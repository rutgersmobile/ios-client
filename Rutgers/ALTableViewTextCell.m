//
//  ALTableViewTextCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/4/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ALTableViewTextCell.h"

@interface ALTableViewTextCell ()
@property (strong, nonatomic) IBOutlet UILabel *attributedTextLabel;
@end

@implementation ALTableViewTextCell

-(UILabel *)textLabel{
    return self.attributedTextLabel;
}

-(void)makeSubviews{
    self.attributedTextLabel = [UILabel newAutoLayoutView];
    self.attributedTextLabel.numberOfLines = 0;
    [self.contentView addSubview:self.attributedTextLabel];
}
-(void)makeConstraints{
    UIEdgeInsets standardInsets = UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets, kLabelVerticalInsets, 0);
    [self.attributedTextLabel autoPinEdgesToSuperviewEdgesWithInsets:standardInsets];
}

-(void)didLayoutSubviews{
    self.attributedTextLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.attributedTextLabel.frame);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
