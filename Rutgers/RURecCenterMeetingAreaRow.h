//
//  RURecCenterMeetingAreaRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/27/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewRow.h"

@interface RURecCenterMeetingAreaRow : EZTableViewRow
-(void)setDate:(NSString *)date;
-(id)initWithArea:(NSString *)area dates:(NSDictionary *)dates;
@end
