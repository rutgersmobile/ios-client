//
//  RUArrival.m
//  Rutgers
//
//  Created by Open Systems Solutions on 8/12/15.
//  Copyright © 2015 Rutgers. All rights reserved.
//

#import "RUBusArrival.h"

@implementation RUBusArrival
-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        _minutes = [dictionary[@"minutes"] integerValue];
        _seconds = [dictionary[@"seconds"] integerValue];
        _vehicle = dictionary[@"vehicle"];
    }
    return self;
}
@end
