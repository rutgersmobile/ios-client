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
-(instancetype)initWithSportID:(NSString *)sportID{
    self = [super init];
    if (self) {
        self.sportID = sportID;
        self.title = @"Schedule";
    }
    return self;
}

-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [RUSportsData getScheduleForSportID:self.sportID withSuccess:^(NSArray *response) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            
            [loading updateWithContent:^(typeof(self) me) {
                
            }];
        } failure:^{
            [loading doneWithError:nil];
        }];
    }];
}
@end
