//
//  RUReaderTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUReaderTableViewCell.h"

@implementation RUReaderTableViewCell

- (void)awakeFromNib
{
    self.detailLabel.numberOfLines = 0;
    self.titleLabel.numberOfLines = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

@end
