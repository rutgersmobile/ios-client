//
//  BusDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUBusData.h"
#import "RUBusDataSource.h"
#import "ComposedDataSource.h"
#import "ActiveRoutesDataSource.h"
#import "ActiveStopsDataSource.h"
#import "NearbyActiveStopsDataSource.h"
#import "AllRoutesDataSource.h"
#import "AllStopsDataSource.h"
#import "RUBusDataLoadingManager.h"

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
        
        ComposedDataSource *stops = [[ComposedDataSource alloc] init];
        stops.title = @"Stops";
        [stops addDataSource:[[NearbyActiveStopsDataSource alloc] init]];
        
        ComposedDataSource *all = [[ComposedDataSource alloc] init];
        all.title = @"All";
        
        dispatch_block_t addNewBrunswickData = ^{
            [routes addDataSource:[[ActiveRoutesDataSource alloc] initWithAgency:newBrunswickAgency]];
            [stops addDataSource:[[ActiveStopsDataSource alloc] initWithAgency:newBrunswickAgency]];
            
            [all addDataSource:[[AllRoutesDataSource alloc] initWithAgency:newBrunswickAgency]];
            [all addDataSource:[[AllStopsDataSource alloc] initWithAgency:newBrunswickAgency]];
        };
        
        dispatch_block_t addNewarkData = ^{
            [routes addDataSource:[[ActiveRoutesDataSource alloc] initWithAgency:newarkAgency]];
            [stops addDataSource:[[ActiveStopsDataSource alloc] initWithAgency:newarkAgency]];
            
            [all addDataSource:[[AllRoutesDataSource alloc] initWithAgency:newarkAgency]];
            [all addDataSource:[[AllStopsDataSource alloc] initWithAgency:newarkAgency]];
        };
        
        addNewBrunswickData();
        addNewarkData();

        [self addDataSource:routes];
        [self addDataSource:stops];
        [self addDataSource:all];
    }
    return self;
}

-(void)startUpdates{
    self.refreshTimer = [MSWeakTimer scheduledTimerWithTimeInterval:UPDATE_TIME_INTERVAL target:self selector:@selector(setNeedsLoadContent) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
}

-(void)stopUpdates{
    [self.refreshTimer invalidate];
}
@end
