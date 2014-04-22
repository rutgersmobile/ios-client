//
//  RUBusStop.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUBusStop.h"

@implementation RUBusStop
-(id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.title = dictionary[@"title"];
        CLLocationDegrees lat = [dictionary[@"lat"] doubleValue];
        CLLocationDegrees lon = [dictionary[@"lon"] doubleValue];
        self.coordinate = CLLocationCoordinate2DMake(lat, lon);
        self.stopId = [dictionary[@"stopId"] integerValue];
    }
    return self;
}
@end 
