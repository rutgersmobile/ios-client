//
//  ScheduleDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ScheduleDataSource.h"
#import "RUSportsData.h"

@implementation ScheduleDataSource
-(id)initWithSportID:(NSString *)sportID{
    self = [super init];
    if (self) {
        self.sportID = sportID;
        self.title = @"Schedule";
    }
    return self;
}

-(void)loadContent{
    [RUSportsData getScheduleForSportID:self.sportID withSuccess:^(NSArray *response) {
        
    } failure:^{
        
    }];
}
@end
