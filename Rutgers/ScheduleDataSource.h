//
//  ScheduleDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "BasicDataSource.h"

@interface ScheduleDataSource : BasicDataSource
-(id)initWithSportID:(NSString *)sportID;
@property (nonatomic) NSString *sportID;
@end
