//
//  RUPredictionsExtraRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPredictionsBodyRow.h"
#import "RUPredictionsBodyTableViewCell.h"
#import "NSDate+EpochTime.h"
#import "RUBusPrediction.h"
#import "RUArrival.h"

@interface RUPredictionsBodyRow ()
@property (nonatomic) NSArray *predictionTimes;
@property (nonatomic) NSString *minutesString;
@property (nonatomic) NSString *descriptionString;
@property (nonatomic) NSString *timeString;
@end

@implementation RUPredictionsBodyRow
-(instancetype)initWithPredictions:(RUBusPrediction *)predictions{
    self = [super init];
    if (self) {
        self.predictionTimes = predictions.arrivals;
    }
    return self;
}

-(void)setPredictionTimes:(NSArray *)predictionTimes{
    _predictionTimes = predictionTimes;
    
    NSMutableString *minutesString = [NSMutableString new];
    NSMutableString *descriptionString = [NSMutableString new];
    NSMutableString *timeString = [NSMutableString new];
    
    [self.predictionTimes enumerateObjectsUsingBlock:^(RUArrival *arrivals, NSUInteger idx, BOOL *stop) {
        NSInteger minutes = arrivals.minutes;
        NSInteger seconds = arrivals.seconds;
        
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:seconds];
        
        if (idx != 0) {
            [minutesString appendString:@"\n"];
            [descriptionString appendString:@"\n"];
            [timeString appendString:@"\n"];
        }
        
        if (minutes == 0) {
            [minutesString appendFormat:@"%ld",(long)seconds];
            [descriptionString appendString:@"seconds at"];
        } else {
            [minutesString appendFormat:@"%ld",(long)minutes];
            if (minutes == 1) {
                [descriptionString appendString:@"minute at"];
            } else {
                [descriptionString appendString:@"minutes at"];
            }
        }
        [timeString appendString:[self formatDate:date]];
    }];

    self.minutesString = minutesString;
    self.descriptionString = descriptionString;
    self.timeString = timeString;
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
@end
