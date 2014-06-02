//
//  RUPredictionTableViewCell.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/24/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALTableViewAbstractCell.h"

@interface RUPredictionsTableViewCell : ALTableViewAbstractCell
-(void)setTitle:(NSString *)title;
-(void)setDirection:(NSString *)direction;
-(void)setTime:(NSString *)time;
-(void)setTimeColor:(UIColor *)color;
@end