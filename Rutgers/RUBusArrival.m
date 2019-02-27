//
//  RUArrival.m
//  Rutgers
//
//  Created by Open Systems Solutions on 8/12/15.
//  Copyright © 2015 Rutgers. All rights reserved.
//

#import "RUBusArrival.h"

@implementation RUBusArrival
-(instancetype)initWithDictionary:(NSDictionary *)dictionary generatedOn: (NSDate*)genDate {
    self = [super init];
    if (self) {
        
        _route_id = dictionary[@"route_id"];
        _vehicle = dictionary[@"vehicle_id"];
        NSString* arrivalDateString = dictionary[@"arrival_at"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZZ"];
        NSDate *date = [dateFormatter dateFromString:arrivalDateString];
        NSTimeInterval marginOfError = [genDate timeIntervalSinceNow]; //System clock - generatedOn
        NSDate* newDate = [[NSDate date] dateByAddingTimeInterval:marginOfError];
        NSTimeInterval diff = [date timeIntervalSinceDate:newDate]; //Need to compare to arrival at
        NSDate* savedDate = [newDate dateByAddingTimeInterval:diff];
        _savedDate = savedDate;
        _minutes = diff/60;
        _seconds = diff;
        
    }
    return self;
}
@end
