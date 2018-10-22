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
        _route_id = dictionary[@"route_id"];
        _vehicle = dictionary[@"vehicle_id"];
        NSString* arrivalDateString = dictionary[@"arrival_at"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss-hh:ss"];
        NSDate *date = [dateFormatter dateFromString:arrivalDateString];
        _savedDate = date;

        
        NSDateFormatter* minutesFormatter = [[NSDateFormatter alloc] init];
        [minutesFormatter setDateFormat:@"m"];
        
        NSDateFormatter* secondsFormatter = [[NSDateFormatter alloc] init];
        [secondsFormatter setDateFormat:@"s"];
        
        NSString* minutesString = [minutesFormatter stringFromDate:date];
        NSString* secondsString = [secondsFormatter stringFromDate:date];
        
        _minutes = [minutesString integerValue];
        _seconds = [secondsString integerValue];
        
    }
    return self;
}
@end
