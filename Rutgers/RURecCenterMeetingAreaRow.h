//
//  RURecCenterMeetingAreaRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/27/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewRightDetailRow.h"

@interface RURecCenterMeetingAreaRow : EZTableViewRightDetailRow
@property (nonatomic) NSString *date;
-(instancetype)initWithArea:(NSString *)area times:(NSDictionary *)dates;
@end
