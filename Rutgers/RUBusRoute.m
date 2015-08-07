//
//  RUBusRoute.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUBusRoute.h"

@implementation RUBusRoute
-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        _title = dictionary[@"title"];
        _stops = dictionary[@"stops"];
    }
    return self;
}
@end
