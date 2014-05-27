//
//  RURecCenterHoursHeaderTableViewCell.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZTableViewCell.h"

@interface RURecCenterHoursHeaderTableViewCell : EZTableViewAbstractCell
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) UIButton *leftButton;
@property (strong, nonatomic) UIButton *rightButton;
@end
