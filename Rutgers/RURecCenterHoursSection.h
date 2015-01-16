//
//  RURecHoursSection.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "BasicDataSource.h"

@interface RURecCenterHoursSection : BasicDataSource
-(instancetype)initWithDailySchedules:(NSArray *)dailySchedules;
-(void)goLeft;
-(void)goRight;
@end
