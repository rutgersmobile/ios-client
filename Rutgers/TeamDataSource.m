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

@interface TeamDataSource ()
@property RosterDataSource *rosterDataSource;

@end

@implementation TeamDataSource
-(id)initWithSportID:(NSString *)sportID{
    self = [super init];
    if (self) {
        self.sportID = sportID;
        
        [self addDataSource:[[ScheduleDataSource alloc] initWithSportID:sportID]];
        
        self.rosterDataSource = [[RosterDataSource alloc] initWithSportID:sportID];
        [self addDataSource:self.rosterDataSource];
    }
    return self;
}
-(void)toggleExpansionForPlayer:(RUSportsPlayer *)player{
    [self.rosterDataSource toggleExpansionForPlayer:player];
}
@end
