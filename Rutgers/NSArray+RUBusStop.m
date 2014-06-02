//
//  NSArray+RUBusStop.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NSArray+RUBusStop.h"
#import "RUBusStop.h"

@implementation NSArray (RUBusStop)
-(NSString *)title{
    return [[self firstObject] title];
}
-(BOOL)active{
    for (RUBusStop *stop in self) {
        if (stop.active) return YES;
    }
    return NO;
}
-(NSString *)agency{
    return [[self firstObject] agency];
}
-(BOOL)isArrayOfBusStops{
    return [[self firstObject] isKindOfClass:[RUBusStop class]];
}
-(CLLocation *)location{
    CLLocationDegrees lat = 0;
    CLLocationDegrees lon = 0;
    for (RUBusStop *stop in self) {
        CLLocationCoordinate2D coordinate = stop.location.coordinate;
        lat += coordinate.latitude;
        lon += coordinate.longitude;
    }
    double count = self.count;
    return [[CLLocation alloc] initWithLatitude:lat/count longitude:lon/count];
}
@end
