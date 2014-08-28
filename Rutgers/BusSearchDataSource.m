//
//  BusSearchDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "BusSearchDataSource.h"
#import "BusBasicDataSource.h"
#import "RUBusDataLoadingManager.h"

@interface BusSearchDataSource ()
@property (nonatomic) BusBasicDataSource *routes;
@property (nonatomic) BusBasicDataSource *stops;
@end

@implementation BusSearchDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.routes = [[BusBasicDataSource alloc] init];
        self.routes.title = @"Routes";
        self.routes.itemLimit = 15;

        self.stops = [[BusBasicDataSource alloc] init];
        self.stops.title = @"Stops";
        self.stops.itemLimit = 30;
        
        [self addDataSource:self.routes];
        [self addDataSource:self.stops];
    }
    return self;
}

-(void)updateForQuery:(NSString *)query{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUBusDataLoadingManager sharedInstance] queryStopsAndRoutesWithString:query completion:^(NSArray *routes, NSArray *stops) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            
            [loading updateWithContent:^(typeof(self) me) {
                me.routes.items = routes;
                me.stops.items = stops;
            }];
        }];
    }];
}
@end
