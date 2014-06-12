//
//  RUPredictionsExtraRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPredictionsBodyRow.h"

@interface RUPredictionsBodyRow ()
@end

@implementation RUPredictionsBodyRow
-(instancetype)initWithPredictionTimes:(NSArray *)predictionTimes{
    self = [super init];
    if (self) {
        self.predictionTimes = predictionTimes;
    }
    return self;
}
-(void)setPredictionTimes:(NSArray *)predictionTimes{
    _predictionTimes = predictionTimes;

    self.attributedString = [[NSAttributedString alloc] initWithString:[self labelString] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]}];
}
-(NSString *)formatDate:(NSDate *)date{
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    });
    return [dateFormatter stringFromDate:date];
}
-(NSString *)labelString{
    NSMutableString *labelString = [[NSMutableString alloc] init];
    for (NSDictionary *prediction in self.predictionTimes) {
        NSString *minutes = prediction[@"_minutes"];
        NSInteger seconds = [prediction[@"_seconds"] integerValue];
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:seconds];
        [labelString appendFormat:@"%@ minutes at %@ \n",minutes,[self formatDate:date]];
    }
    return labelString;
}
@end
