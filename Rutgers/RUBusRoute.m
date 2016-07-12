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
        _title = dictionary[@"title"];
        _stops = dictionary[@"stops"];
        NSLog(@" route : %@", self.title);
    }
    return self;
}
@end
