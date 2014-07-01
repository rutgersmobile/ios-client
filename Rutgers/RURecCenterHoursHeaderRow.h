//
//  RURecCenterHoursHeaderRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/27/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewRightDetailRow.h"

@interface RURecCenterHoursHeaderRow : EZTableViewRightDetailRow
@property (nonatomic) NSString *date;

@property (nonatomic) BOOL leftButtonEnabled;
@property (nonatomic) BOOL rightButtonEnabled;
@end
