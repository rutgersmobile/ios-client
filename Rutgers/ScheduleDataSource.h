//
//  ScheduleDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "BasicDataSource.h"

@interface ScheduleDataSource : BasicDataSource
-(instancetype)initWithSportID:(NSString *)sportID NS_DESIGNATED_INITIALIZER;
@property (nonatomic) NSString *sportID;
@end
