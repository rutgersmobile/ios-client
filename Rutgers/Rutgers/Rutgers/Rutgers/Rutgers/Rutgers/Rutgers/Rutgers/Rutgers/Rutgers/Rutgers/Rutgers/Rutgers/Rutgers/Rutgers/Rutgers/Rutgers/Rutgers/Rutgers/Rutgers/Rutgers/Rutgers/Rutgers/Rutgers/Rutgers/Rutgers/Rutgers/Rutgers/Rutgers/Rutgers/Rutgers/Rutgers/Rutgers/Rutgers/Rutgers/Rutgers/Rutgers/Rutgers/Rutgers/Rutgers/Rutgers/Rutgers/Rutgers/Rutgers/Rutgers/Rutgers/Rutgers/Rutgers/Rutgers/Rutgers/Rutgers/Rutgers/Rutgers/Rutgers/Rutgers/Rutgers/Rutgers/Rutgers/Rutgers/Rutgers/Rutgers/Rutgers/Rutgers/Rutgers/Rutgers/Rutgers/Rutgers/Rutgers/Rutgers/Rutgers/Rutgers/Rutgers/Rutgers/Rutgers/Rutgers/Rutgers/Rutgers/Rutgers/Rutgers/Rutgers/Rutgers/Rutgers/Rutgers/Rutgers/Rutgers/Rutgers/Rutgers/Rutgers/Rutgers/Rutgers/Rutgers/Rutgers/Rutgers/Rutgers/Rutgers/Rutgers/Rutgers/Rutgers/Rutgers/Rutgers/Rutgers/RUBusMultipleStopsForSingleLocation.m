//
//  RUMultiStop.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/13/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUBusMultipleStopsForSingleLocation.h"
#import "RUBusStop.h"
#import "CLLocation+Centroid.h"

/*
    Some Locations have multiple Stops corresponding to them .
        This happens because there might be multipe stops near that location . 
        Or it could be because the buses move in two different directions at the stop

    All Such stops will have the stop tag differnt , but there stop title will be the same when the data is obtained from the server .. 
    This title data is used to group the stops corresponding to a single location together
 
 */
@implementation RUBusMultipleStopsForSingleLocation

/*
    called by the RUBusDataAcencyManager parseRouteConfig function
 */
-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _stops = @[];
    }
    return self;
}
-(NSString *)title
{
    return [[self.stops firstObject] title];
}

-(NSString *)agency // agency refers to the Rutgers New brunwish agency etc... NextBus has multiple agencies ..
{
    return [[self.stops firstObject] agency];
}

-(void)addStopsObject:(RUBusStop *)object
{
    _stops = [self.stops arrayByAddingObject:object];
}

/*
    Returns the centroid of all the locations in the stops array
 */
-(CLLocation *)location
{
    return [CLLocation centroidOfLocations:[self.stops valueForKey:@"location"]];
}

-(NSString *)description
{
    return [self.stops description]; // provides all the data in the array as string , in the form of a plist
}
@end
