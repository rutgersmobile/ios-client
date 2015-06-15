//
//  RUBusStop.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUBusStop.h"

@implementation RUBusStop
-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.routes = @[];
        self.title = dictionary[@"title"];
        CLLocationDegrees lat = [dictionary[@"lat"] doubleValue];
        CLLocationDegrees lon = [dictionary[@"lon"] doubleValue];
        self.location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        self.stopId = [dictionary[@"stopId"] integerValue];
    }
    return self;
}

-(NSArray *)activeRoutes{
    return [self.routes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"active = YES"]];
}

-(NSString *)description{
    return self.title;
}
@end 
