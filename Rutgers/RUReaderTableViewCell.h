//
//  RUReaderTableViewCell.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZTableViewAbstractCell.h"

@interface RUReaderTableViewCell : EZTableViewAbstractCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@end
