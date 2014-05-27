//
//  RURecCenterHoursHeaderRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/27/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewRow.h"

@interface RURecCenterHoursHeaderRow : EZTableViewRow
-(void)setDate:(NSString *)date;

@property BOOL leftButtonEnabled;
@property BOOL rightButtonEnabled;
@end
