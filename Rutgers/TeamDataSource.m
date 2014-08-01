//
//  TeamDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "TeamDataSource.h"
#import "ScheduleDataSource.h"
#import "RosterDataSource.h"

@implementation TeamDataSource
-(id)initWithSportID:(NSString *)sportID{
    self = [super init];
    if (self) {
        self.sportID = sportID;
        [self addDataSource:[[ScheduleDataSource alloc] initWithSportID:sportID]];
        [self addDataSource:[[RosterDataSource alloc] initWithSportID:sportID]];
    }
    return self;
}
@end
