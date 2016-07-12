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
        self.routes = @[]; // filled up in the parseConfig method
        self.title = dictionary[@"title"];
        
        CLLocationDegrees lat = [dictionary[@"lat"] doubleValue];
        CLLocationDegrees lon = [dictionary[@"lon"] doubleValue];
        
        self.location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        self.stopId = [dictionary[@"stopId"] integerValue];
        
        NSLog(@" stop : %@", self.title);
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
