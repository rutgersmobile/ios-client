//
//  BusDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUBusDataSource.h"
#import "ComposedDataSource.h"
#import "ActiveRoutesDataSource.h"
#import "ActiveStopsDataSource.h"
#import "NearbyActiveStopsDataSource.h"
#import "AllRoutesDataSource.h"
#import "AllStopsDataSource.h"
#import "RUBusDataLoadingManager.h"
#import "RULocationManager.h"
#import "RUUserInfoManager.h"

#define UPDATE_TIME_INTERVAL 60.0

@interface RUBusDataSource ()
@property MSWeakTimer *refreshTimer;
@end

@implementation RUBusDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        ComposedDataSource *routes = [[ComposedDataSource alloc] init];
        routes.title = @"Routes";
        routes.singleLoadingIndicator = YES;
        routes.noContentTitle = @"No Active Routes";
        
        ComposedDataSource *stops = [[ComposedDataSource alloc] init];
        stops.title = @"Stops";
        stops.singleLoadingIndicator = YES;
        stops.noContentTitle = @"No Active Stops";
        
        ComposedDataSource *all = [[ComposedDataSource alloc] init];
        all.title = @"All";
        all.singleLoadingIndicator = YES;
        
        [stops addDataSource:[[NearbyActiveStopsDataSource alloc] init]];
        
        void (^addDataForAgency)(NSString *agency) = ^void (NSString *agency) {
            
            [routes addDataSource:[[ActiveRoutesDataSource alloc] initWithAgency:agency]];
            [stops addDataSource:[[ActiveStopsDataSource alloc] initWithAgency:agency]];
            
            [all addDataSource:[[AllRoutesDataSource alloc] initWithAgency:agency]];
            [all addDataSource:[[AllStopsDataSource alloc] initWithAgency:agency]];
            
        };
        
        [RUUserInfoManager performInCampusPriorityOrderWithNewBrunswickBlock:^{
            addDataForAgency(newBrunswickAgency);
        } newarkBlock:^{
            addDataForAgency(newarkAgency);
        } camdenBlock:nil];

        [self addDataSource:routes];
        [self addDataSource:stops];
        [self addDataSource:all];
    }
    return self;
}

-(void)startUpdates{
    self.refreshTimer = [MSWeakTimer scheduledTimerWithTimeInterval:UPDATE_TIME_INTERVAL target:self selector:@selector(setNeedsLoadContent) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
    [self setNeedsLoadContent];
    [[RULocationManager sharedLocationManager] startUpdatingLocation];
}

-(void)stopUpdates{
    [self.refreshTimer invalidate];
    [[RULocationManager sharedLocationManager] stopUpdatingLocation];
}
@end
