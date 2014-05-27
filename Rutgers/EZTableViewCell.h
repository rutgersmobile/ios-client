//
//  EZTableViewCell.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZTableViewAbstractCell.h"

#define kLabelHorizontalInsets      15.0f
#define kLabelVerticalInsets        11.0f

@interface EZTableViewCell : EZTableViewAbstractCell
-(UILabel *)textLabel;
-(UILabel *)detailTextLabel;
@end
