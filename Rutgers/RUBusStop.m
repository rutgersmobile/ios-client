//
//  RUBusStop.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUBusStop.h"

@implementation RUBusStop

/*
    Obtain data from the servers as a dictionary and then use it to create the bus stop objects
 
 
    called by the parse Route Config in RUBusDataAgencyManager
 
 */
-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self)
    {
        _routes = dictionary[@"routes"] != nil ? dictionary[@"routes"] : [[NSArray alloc] init];
        _title = dictionary[@"name"] != nil ? dictionary[@"name"] : @"";
        
        CLLocationDegrees lat = dictionary[@"location"][@"lat"] != nil ? [dictionary[@"location"][@"lat"] doubleValue] : 0.0;
        CLLocationDegrees lon = dictionary[@"location"][@"lng"] != nil ? [dictionary[@"location"][@"lng"] doubleValue] : 0.0;
        
        _location = [[CLLocation alloc] initWithLatitude:lat longitude: lon];
        _stopId = dictionary[@"stop_id"] != nil ? [dictionary[@"stop_id"] integerValue] : 0;
        _active = !_routes.count ? NO : YES;
    }
    
    return self;
}

/*
    Get the routes that are active for the current stop from all the stops
 */
-(NSArray *)activeRoutes
{
    return [self.routes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"active = YES"]];
}

-(NSString *)description
{
    return self.title;
}
@end 
