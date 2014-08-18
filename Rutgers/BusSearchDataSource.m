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
        self.itemLimit = 35;
    }
    return self;
}

-(void)updateForQuery:(NSString *)query{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUBusDataLoadingManager sharedInstance] queryStopsAndRoutesWithString:query completion:^(NSArray *results) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            
            [loading updateWithContent:^(typeof(self) me) {
                me.items = results;
            }];
        }];
    }];
}
@end
