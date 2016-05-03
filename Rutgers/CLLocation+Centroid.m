//
//  CLLocation+Centroid.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/13/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

/*
    Descript : 
        Centroid of an array locations
        Calculated by adding the lat and div by # locations
        Same for long
 */

#import "CLLocation+Centroid.h"

@implementation CLLocation (Centroid)
+(CLLocation *)centroidOfLocations:(NSArray *)locations{
    CLLocationDegrees lat = 0;
    CLLocationDegrees lon = 0;
    for (CLLocation *location in locations) {
        CLLocationCoordinate2D coordinate = location.coordinate;
        lat += coordinate.latitude;
        lon += coordinate.longitude;
    }
    return [[CLLocation alloc] initWithLatitude:lat/locations.count longitude:lon/locations.count];
}
@end
