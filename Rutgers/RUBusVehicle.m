//
//  RUBusVehicle.m
//  Rutgers
//
//  Created by Colin Walsh on 12/4/18.
//  Copyright © 2018 Rutgers. All rights reserved.
//

#import "RUBusVehicle.h"

@implementation RUBusVehicle

-(instancetype)initWithDictionary: (NSDictionary*)response {
    self = [super init];
    if (self) {
        _arrivals = (NSArray*)response[@"arrival_estimates"];
        _doesHaveArrivals = [_arrivals count] > 0 ? YES : NO;
        NSDictionary* locationDict = response[@"location"];
        CLLocation* locObj = [[CLLocation alloc] initWithLatitude:[locationDict[@"lat"] doubleValue] longitude:[locationDict[@"lng"] doubleValue]];
        _location = locObj;
        _nearbyStop = [RUBusStop alloc];
        _routeId = response[@"route_id"];
        _trackingStatus = response[@"tracking_status"];
        _vehicleId = response[@"vehicle_id"];
    }
    return self;
}

@end
