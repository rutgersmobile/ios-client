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

@property (nonatomic) BOOL leftButtonEnabled;
@property (nonatomic) BOOL rightButtonEnabled;
@end
