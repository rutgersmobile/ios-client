//
//  RURecHoursSection.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZDataSourceSection.h"

@interface RURecCenterHoursSection : EZDataSourceSection
-(instancetype)initWithMeetingAreas:(NSDictionary *)meetingAreas;
-(void)goLeft;
-(void)goRight;
@end
