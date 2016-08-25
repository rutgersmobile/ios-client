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
@property (nonatomic) BusBasicDataSource *routesDataSource;
@property (nonatomic) BusBasicDataSource *stopsDataSource;
@end

@implementation BusSearchDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.routesDataSource = [[BusBasicDataSource alloc] init];
        self.routesDataSource.title = @"Routes";
        self.routesDataSource.noContentTitle = @"No matching routes";

        self.stopsDataSource = [[BusBasicDataSource alloc] init];
        self.stopsDataSource.title = @"Stops";
        self.stopsDataSource.noContentTitle = @"No matching stops";
        
        [self addDataSource:self.routesDataSource];
        [self addDataSource:self.stopsDataSource];
    }
    return self;
}

-(void)updateForQuery:(NSString *)query{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUBusDataLoadingManager sharedInstance] queryStopsAndRoutesWithString:query completion:^(NSArray *routes, NSArray *stops, NSError *error) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            if (!error) {
                [loading updateWithContent:^(typeof(self) me) {
                    [me.routesDataSource loadContentWithBlock:^(AAPLLoading *loading) {
                        [loading updateWithContent:^(typeof(self.routesDataSource) routesDataSource) {
                            routesDataSource.items = routes;
                        }];
                    }];
                    
                    [me.stopsDataSource loadContentWithBlock:^(AAPLLoading *loading) {
                        [loading updateWithContent:^(typeof(self.stopsDataSource) stopsDataSource) {
                            stopsDataSource.items = stops;
                        }];
                    }];
                }];
            } else {
                [loading doneWithError:error];
            }
        }];
    }];
}
@end
