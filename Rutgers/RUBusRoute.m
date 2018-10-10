//
//  RUBusRoute.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUBusRoute.h"

@implementation RUBusRoute

/*
    Create route object from the data from the Rutgers server : 
    called by the parse Route Config function

    active controls where the route is active or not 
 */
-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    
    if (self)
    {
        //_title = dictionary[@"title"];
        //_stops = dictionary[@"stops"];
        _title = dictionary[@"long_name"];
        _stops = dictionary[@"stops"];
        _active = [dictionary[@"is_active"] boolValue];
        _route_id = dictionary[@"route_id"];
    }
    return self;
}
@end
