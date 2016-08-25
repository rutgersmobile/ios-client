//
//  NSDate+EpochTime.m
//  Rutgers
//
//  Created by Open Systems Solutions on 2/4/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import "NSDate+EpochTime.h"

@implementation NSDate (EpochTime)
+(NSDate *)dateWithEpochTime:(NSString *)epochTime{
    long long epochTimeValue = [epochTime longLongValue];
    NSTimeInterval timeInterval = epochTimeValue / 1000.0;
    return [NSDate dateWithTimeIntervalSince1970:timeInterval];
}
@end
