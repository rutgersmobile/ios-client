//
//  BusSearchDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "BusSearchDataSource.h"
#import "RUBusDataLoadingManager.h"

@implementation BusSearchDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.itemLimit = 25;
    }
    return self;
}

-(void)updateForSearchString:(NSString *)searchString{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUBusDataLoadingManager sharedInstance] queryStopsAndRoutesWithString:searchString completion:^(NSArray *results) {
            [loading updateWithContent:^(typeof(self) me) {
                me.items = results;
            }];
        }];
    }];
}
@end
