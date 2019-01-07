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
        NSString* truncateDate = [arrivalDateString substringToIndex: [arrivalDateString length] - 6];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        NSDate *date = [dateFormatter dateFromString:truncateDate];
        _savedDate = date;
        
        NSTimeInterval diff = [date timeIntervalSinceNow];
        
        _minutes = diff/60;
        _seconds = diff;
        
    }
    return self;
}
@end
