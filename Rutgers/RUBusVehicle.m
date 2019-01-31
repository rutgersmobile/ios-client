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
        _doesHaveArrivals = [(NSArray*)response[@"arrival_estimates"] count] == 0 ? NO : YES;
        NSDictionary* locationDict = response[@"location"];
        CLLocationDegrees lat = locationDict[@"lat"] != nil ? [locationDict[@"lat"] doubleValue] : 0.0;
        CLLocationDegrees lon = locationDict[@"lng"] != nil ? [locationDict[@"lng"] doubleValue] : 0.0;
        CLLocation* locObj = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        NSNumber* passLoad = response[@"passenger_load"];
        _passengerLoad = [passLoad isEqual: [NSNull null]] ? -1 : [passLoad intValue];
        _location = locObj;
        _nearbyStop = [RUBusStop alloc];
        _routeId = response[@"route_id"];
        _trackingStatus = response[@"tracking_status"];
        //_vehicleId = response[@"vehicle_id"];
        _vehicleId = response[@"vehicle_id"];
        _callName = response[@"call_name"];
    }
    return self;
}

@end
